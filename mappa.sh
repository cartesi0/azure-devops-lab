clear

# ============================================================
# AZURE TREE
#
# Subscription
# ├── Budget
# ├── RBAC
# ├── Lock
# └── Resource Group
#     ├── Tag
#     ├── Budget
#     ├── Lock
#     ├── RBAC
#     ├── VNet
#     │   └── Subnet
#     ├── Storage
#     │   └── Container
#     │       └── Blob
#     ├── VM
#     ├── NIC
#     ├── Public IP
#     └── NSG
# ============================================================


# ------------------------------------------------------------
# CONTROLLO LOGIN
# ------------------------------------------------------------

if ! az account show >/dev/null 2>&1; then
    echo "❌ Non sei autenticato in Azure."
    echo
    echo "Esegui:"
    echo "az login"
    exit 1
fi


# ------------------------------------------------------------
# SUBSCRIPTION
# ------------------------------------------------------------

SUB_NAME=$(az account show --query "name" -o tsv)
SUB_ID=$(az account show --query "id" -o tsv)
SUB_SCOPE="/subscriptions/$SUB_ID"


echo
echo "☁️  AZURE"
echo "└── 🔑 Subscription: $SUB_NAME"
echo "    ├── 🆔 ID: $SUB_ID"


# ============================================================
# BUDGET SUBSCRIPTION
# ============================================================

BUDGETS=$(az consumption budget list \
    --query "[].[name,amount,timeGrain]" \
    -o tsv \
    --only-show-errors 2>/dev/null)

if [ -n "$BUDGETS" ]; then

    echo "    ├── 💰 Budget"

    while IFS=$'\t' read -r budget amount grain; do

        [ -z "$budget" ] && continue

        echo "    │   ├── 💶 $budget"
        echo "    │   │   ├── Limite: $amount"
        echo "    │   │   └── Periodo: $grain"

    done <<< "$BUDGETS"

fi


# ============================================================
# LOCK SUBSCRIPTION
# ============================================================

SUB_LOCKS=$(az lock list \
    --query "[?scope=='$SUB_SCOPE'].[name,level]" \
    -o tsv \
    --only-show-errors 2>/dev/null)

if [ -n "$SUB_LOCKS" ]; then

    echo "    ├── 🔒 Lock Subscription"

    while IFS=$'\t' read -r lock level; do

        [ -z "$lock" ] && continue

        echo "    │   ├── 🔐 $lock"
        echo "    │   │   └── Tipo: $level"

    done <<< "$SUB_LOCKS"

fi


# ============================================================
# RBAC SUBSCRIPTION
# ============================================================

SUB_RBAC=$(az role assignment list \
    --scope "$SUB_SCOPE" \
    --query "[].[principalName,principalId,principalType,roleDefinitionName]" \
    -o tsv \
    --only-show-errors 2>/dev/null)

if [ -n "$SUB_RBAC" ]; then

    echo "    ├── 👤 RBAC Subscription"

    while IFS=$'\t' read -r principal principal_id principal_type role; do

        [ -z "$role" ] && continue

        if [ -z "$principal" ] || [ "$principal" = "None" ]; then
            principal="$principal_id"
        fi

        echo "    │   ├── 👤 $principal"
        echo "    │   │   ├── Tipo: $principal_type"
        echo "    │   │   └── Ruolo: $role"

    done <<< "$SUB_RBAC"

fi


echo "    │"


# ============================================================
# RESOURCE GROUP
# ============================================================

while IFS= read -r rg; do

    [ -z "$rg" ] && continue

    RG_SCOPE="$SUB_SCOPE/resourceGroups/$rg"

    echo "    ├── 📁 Resource Group: $rg"


    # ========================================================
    # LOCATION
    # ========================================================

    RG_LOCATION=$(az group show \
        --name "$rg" \
        --query "location" \
        -o tsv \
        --only-show-errors 2>/dev/null)

    if [ -n "$RG_LOCATION" ]; then
        echo "    │   ├── 📍 Location: $RG_LOCATION"
    fi


    # ========================================================
    # TAG RESOURCE GROUP
    # ========================================================

    TAG_JSON=$(az group show \
        --name "$rg" \
        --query "tags" \
        -o json \
        --only-show-errors 2>/dev/null)

    if [ "$TAG_JSON" != "{}" ] && \
       [ "$TAG_JSON" != "null" ] && \
       [ -n "$TAG_JSON" ]; then

        echo "    │   ├── 🏷️ Tag"

        while IFS= read -r tag; do

            [ -z "$tag" ] && continue

            echo "    │   │   ├── $tag"

        done < <(
            python3 -c '
import json
import sys

try:
    data=json.load(sys.stdin)

    if data:
        for key,value in data.items():
            print(f"{key}={value}")

except:
    pass
' <<< "$TAG_JSON"
        )

    fi


    # ========================================================
    # BUDGET RESOURCE GROUP
    # ========================================================

    RG_BUDGETS=$(az consumption budget list \
        --resource-group "$rg" \
        --query "[].[name,amount,timeGrain]" \
        -o tsv \
        --only-show-errors 2>/dev/null)

    if [ -n "$RG_BUDGETS" ]; then

        echo "    │   ├── 💰 Budget"

        while IFS=$'\t' read -r budget amount grain; do

            [ -z "$budget" ] && continue

            echo "    │   │   ├── 💶 $budget"
            echo "    │   │   │   ├── Limite: $amount"
            echo "    │   │   │   └── Periodo: $grain"

        done <<< "$RG_BUDGETS"

    fi


    # ========================================================
    # LOCK RESOURCE GROUP
    # ========================================================

    RG_LOCKS=$(az group lock list \
        --resource-group "$rg" \
        --query "[].[name,level]" \
        -o tsv \
        --only-show-errors 2>/dev/null)

    if [ -n "$RG_LOCKS" ]; then

        echo "    │   ├── 🔒 Lock"

        while IFS=$'\t' read -r lock level; do

            [ -z "$lock" ] && continue

            echo "    │   │   ├── 🔐 $lock"
            echo "    │   │   │   └── Tipo: $level"

        done <<< "$RG_LOCKS"

    fi


    # ========================================================
    # RBAC RESOURCE GROUP
    # ========================================================

    RG_RBAC=$(az role assignment list \
        --scope "$RG_SCOPE" \
        --query "[].[principalName,principalId,principalType,roleDefinitionName]" \
        -o tsv \
        --only-show-errors 2>/dev/null)

    if [ -n "$RG_RBAC" ]; then

        echo "    │   ├── 👥 RBAC"

        while IFS=$'\t' read -r principal principal_id principal_type role; do

            [ -z "$role" ] && continue

            if [ -z "$principal" ] || [ "$principal" = "None" ]; then
                principal="$principal_id"
            fi

            echo "    │   │   ├── 👤 $principal"
            echo "    │   │   │   ├── Tipo: $principal_type"
            echo "    │   │   │   └── Ruolo: $role"

        done <<< "$RG_RBAC"

    fi


    # ========================================================
    # RISORSE ARM
    # ========================================================

    RESOURCE_FOUND=false

    while IFS=$'\t' read -r name type; do

        [ -z "$name" ] && continue

        RESOURCE_FOUND=true


        case "$type" in


        # ====================================================
        # VIRTUAL NETWORK
        # ====================================================

        "Microsoft.Network/virtualNetworks")

            echo "    │   ├── 🌐 VNet: $name"

            VNET_PREFIXES=$(az network vnet show \
                --resource-group "$rg" \
                --name "$name" \
                --query "addressSpace.addressPrefixes[]" \
                -o tsv \
                --only-show-errors 2>/dev/null)

            while IFS= read -r vnet_prefix; do

                [ -z "$vnet_prefix" ] && continue

                echo "    │   │   ├── 🌍 CIDR VNet: $vnet_prefix"

            done <<< "$VNET_PREFIXES"


            # ================================================
            # SUBNET
            # ================================================

            while IFS= read -r subnet; do

                [ -z "$subnet" ] && continue

                echo "    │   │   ├── 🔹 Subnet: $subnet"


                PREFIXES=$(az network vnet subnet show \
                    --resource-group "$rg" \
                    --vnet-name "$name" \
                    --name "$subnet" \
                    --query "addressPrefixes[]" \
                    -o tsv \
                    --only-show-errors 2>/dev/null)


                # Compatibilità con addressPrefix singolo

                if [ -z "$PREFIXES" ]; then

                    PREFIXES=$(az network vnet subnet show \
                        --resource-group "$rg" \
                        --vnet-name "$name" \
                        --name "$subnet" \
                        --query "addressPrefix" \
                        -o tsv \
                        --only-show-errors 2>/dev/null)

                fi


                if [ -n "$PREFIXES" ] && [ "$PREFIXES" != "None" ]; then

                    while IFS= read -r prefix; do

                        [ -z "$prefix" ] && continue
                        [ "$prefix" = "None" ] && continue

                        echo "    │   │   │   ├── 🌐 CIDR: $prefix"

                    done <<< "$PREFIXES"

                fi


                # ============================================
                # NSG COLLEGATO ALLA SUBNET
                # ============================================

                SUBNET_NSG=$(az network vnet subnet show \
                    --resource-group "$rg" \
                    --vnet-name "$name" \
                    --name "$subnet" \
                    --query "networkSecurityGroup.id" \
                    -o tsv \
                    --only-show-errors 2>/dev/null)

                if [ -n "$SUBNET_NSG" ] && [ "$SUBNET_NSG" != "None" ]; then

                    NSG_NAME="${SUBNET_NSG##*/}"

                    echo "    │   │   │   └── 🛡️ NSG: $NSG_NAME"

                fi


            done < <(
                az network vnet subnet list \
                    --resource-group "$rg" \
                    --vnet-name "$name" \
                    --query "[].name" \
                    -o tsv \
                    --only-show-errors 2>/dev/null
            )

            ;;


        # ====================================================
        # STORAGE ACCOUNT
        # ====================================================

        "Microsoft.Storage/storageAccounts")

            echo "    │   ├── 🗄️ Storage Account: $name"


            CONTAINERS=$(az storage container list \
                --account-name "$name" \
                --auth-mode login \
                --query "[].name" \
                -o tsv \
                --only-show-errors 2>/dev/null)

            STORAGE_RESULT=$?


            if [ $STORAGE_RESULT -ne 0 ]; then

                echo "    │   │   └── 🔒 Container non leggibili"

            elif [ -z "$CONTAINERS" ]; then

                echo "    │   │   └── 📭 Nessun container"

            else

                while IFS= read -r container; do

                    [ -z "$container" ] && continue

                    echo "    │   │   ├── 📦 Container: $container"


                    BLOBS=$(az storage blob list \
                        --account-name "$name" \
                        --container-name "$container" \
                        --auth-mode login \
                        --query "[].name" \
                        -o tsv \
                        --only-show-errors 2>/dev/null)

                    BLOB_RESULT=$?


                    if [ $BLOB_RESULT -ne 0 ]; then

                        echo "    │   │   │   └── 🔒 Blob non leggibili"

                    elif [ -z "$BLOBS" ]; then

                        echo "    │   │   │   └── 📭 Container vuoto"

                    else

                        while IFS= read -r blob; do

                            [ -z "$blob" ] && continue

                            echo "    │   │   │   ├── 📄 $blob"

                        done <<< "$BLOBS"

                    fi

                done <<< "$CONTAINERS"

            fi

            ;;


        # ====================================================
        # NETWORK SECURITY GROUP
        # ====================================================

        "Microsoft.Network/networkSecurityGroups")

            echo "    │   ├── 🛡️ NSG: $name"


            while IFS=$'\t' read -r rule priority access direction port; do

                [ -z "$rule" ] && continue

                echo "    │   │   ├── 📏 $rule"
                echo "    │   │   │   ├── Priority: $priority"
                echo "    │   │   │   ├── Access: $access"
                echo "    │   │   │   ├── Direction: $direction"
                echo "    │   │   │   └── Porta: $port"

            done < <(
                az network nsg rule list \
                    --resource-group "$rg" \
                    --nsg-name "$name" \
                    --query \
                    "[].[name,priority,access,direction,destinationPortRange]" \
                    -o tsv \
                    --only-show-errors 2>/dev/null
            )

            ;;


        # ====================================================
        # PUBLIC IP
        # ====================================================

        "Microsoft.Network/publicIPAddresses")

            IP=$(az network public-ip show \
                --resource-group "$rg" \
                --name "$name" \
                --query "ipAddress" \
                -o tsv \
                --only-show-errors 2>/dev/null)

            echo "    │   ├── 🌍 Public IP: $name"

            if [ -n "$IP" ] && [ "$IP" != "None" ]; then

                echo "    │   │   └── IP: $IP"

            else

                echo "    │   │   └── IP non assegnato"

            fi

            ;;


        # ====================================================
        # NIC
        # ====================================================

        "Microsoft.Network/networkInterfaces")

            echo "    │   ├── 🔌 NIC: $name"


            PRIVATE_IPS=$(az network nic show \
                --resource-group "$rg" \
                --name "$name" \
                --query "ipConfigurations[].privateIPAddress" \
                -o tsv \
                --only-show-errors 2>/dev/null)


            while IFS= read -r private_ip; do

                [ -z "$private_ip" ] && continue

                echo "    │   │   ├── 🏠 Private IP: $private_ip"

            done <<< "$PRIVATE_IPS"

            ;;


        # ====================================================
        # VIRTUAL MACHINE
        # ====================================================

        "Microsoft.Compute/virtualMachines")

            echo "    │   ├── 💻 VM: $name"


            VM_SIZE=$(az vm show \
                --resource-group "$rg" \
                --name "$name" \
                --query "hardwareProfile.vmSize" \
                -o tsv \
                --only-show-errors 2>/dev/null)


            OS_DISK=$(az vm show \
                --resource-group "$rg" \
                --name "$name" \
                --query "storageProfile.osDisk.name" \
                -o tsv \
                --only-show-errors 2>/dev/null)


            if [ -n "$VM_SIZE" ]; then
                echo "    │   │   ├── ⚙️ Size: $VM_SIZE"
            fi


            if [ -n "$OS_DISK" ]; then
                echo "    │   │   └── 💾 OS Disk: $OS_DISK"
            fi

            ;;


        # ====================================================
        # MANAGED DISK
        # ====================================================

        "Microsoft.Compute/disks")

            echo "    │   ├── 💾 Disk: $name"

            ;;


        # ====================================================
        # NETWORK WATCHER
        # ====================================================

        "Microsoft.Network/networkWatchers")

            echo "    │   ├── 👁️ Network Watcher: $name"

            ;;


        # ====================================================
        # ALTRE RISORSE
        # ====================================================

        *)

            echo "    │   ├── ⚙️ $name"
            echo "    │   │   └── $type"

            ;;

        esac


    done < <(

        az resource list \
            --resource-group "$rg" \
            --query "[].[name,type]" \
            -o tsv \
            --only-show-errors

    )


    # Se non ci sono risorse ARM vere e proprie

    if [ "$RESOURCE_FOUND" = false ]; then

        echo "    │   └── 📭 Nessuna risorsa ARM"

    fi


    echo "    │"

done < <(

    az group list \
        --query "sort_by(@, &name)[].name" \
        -o tsv \
        --only-show-errors

)


echo "    └── ✅ Analisi Azure completata."
echo
