#!/usr/bin/env bash

latestexefs=$(ls ./*.exefs)
latestexefs=${latestexefs:2}
latestjson=${latestexefs:0:-6}.json
dd if="$latestexefs" of="otp.bin" bs=1 skip=3072 count=256 status=none
dd if="$latestexefs" of="secinfo.bin" bs=1 skip=1024 count=273 status=none
if ! cleaninty ctr GenJson --otp otp.bin --secureinfo secinfo.bin --region JPN --country jp --out "$latestjson" | grep -q "Complete!"; then echo "The target's json could not be compiled. Check whether your constants are set up correctly and if the exefs_mount folder has anything in it." && exit 2; fi
cleaninty ctr CheckReg --console "$latestjson"
jsonregion=$(grep -oP '(?<="region": ")[A-Z]{3}(?=",)' <"$latestjson")
jsoncountry=$(grep -oP '(?<="country": ")[A-Z]{2}(?=",)' <"$latestjson")
jsonlanguage=$(grep -oP '(?<="language": ")[a-z]{2}(?=",)' <"$latestjson")
echo "Current JSON's region: $jsonregion"
rm -f otp.bin secinfo.bin

clear
while true; do
    printf "Current JSON: %s\nCurrent JSON's region: %s\nPlease select the region to change to: (USA, EUR, JPN, CHN, KOR, TWN)\n>" "$latestjson" "$jsonregion"
    read -p "Region: " -n 3 regionchange && printf "\n"
    regionchange="${regionchange^^}"
    if [[ "$regionchange" =~ ^(USA|EUR|JPN|CHN|KOR|TWN) ]]; then
        if [[ "$regionchange" != "$jsonregion" ]]; then
            echo "Valid region selected. Changing from $jsonregion to $regionchange."
            break
        else
            echo "You cannot change to the same region. Please choose a different one."
            continue
        fi
    else
        echo "Invalid region. Please choose a valid region."
        continue
    fi
done

if [[ "$regionchange" =~ ^((USA|EUR|TWN)) ]]; then
    validcountry=0
    while [[ "$validcountry" == 0 ]]; do
        echo "Please select the country to change to:"
        case "$regionchange" in
        "USA")
            echo "Valid countries: AI, AG, AR, AW, BS, BB, BZ, BM, BO, BR, VG, CA, KY, CL, CO, CR, DM, DO, EC, SV, GF, GD, GP, GT, GY, HT, HN, JM, MY, MQ, MX, MS, AN, NI, PA, PY, PE, SA, SG, KN, LC, VC, SR, TT, TC, AE, US, UY, VI, VE"
            echo "If you are unsure, pick US."
            ;;
        "EUR")
            echo "Valid countries: AL, AD, AU, AT, AZ, BE, BA, BW, BG, TD, HR, CY, CZ, DK, DJ, ER, EE, FI, FR, DE, GI, GR, GG, HU, IS, IN, IE, IM, IT, JE, LV, LS, LI, LT, LU, MK, ML, MT, MR, MC, ME, MZ, NA, NL, NZ, NE, NO, PL, PT, RO, RU, SM, RS, SK, SI, SO, ZA, ES, SD, SZ, SE, CH, TR, GB, VA, ZM, ZW"
            ;;
        "TWN")
            echo "Valid countries: TW, HK"
            ;;
        *)
            echo "The chosen region was not found. This should not be possible."
            exit 2
            ;;
        esac
        read -p "Country: " -n 2 countrychange && printf "\n"
        countrychange="${countrychange^^}"
        case "$regionchange" in
        "USA")
            if [[ "$countrychange" =~ ^(AI|AG|AR|AW|BS|BB|BZ|BM|BO|BR|VG|CA|KY|CL|CO|CR|DM|DO|EC|SV|GF|GD|GP|GT|GY|HT|HN|JM|MY|MQ|MX|MS|AN|NI|PA|PY|PE|SA|SG|KN|LC|VC|SR|TT|TC|AE|US|UY|VI|VE) ]]; then
                validcountry=1
                languagechange=en
                echo "Country and language set to $countrychange $languagechange."
            else
                echo "Invalid country for this region. Please choose a valid country."
            fi
            ;;
        "EUR")
            if [[ "$countrychange" =~ ^(AL|AD|AU|AT|AZ|BE|BA|BW|BG|TD|HR|CY|CZ|DK|DJ|ER|EE|FI|FR|DE|GI|GR|GG|HU|IS|IN|IE|IM|IT|JE|LV|LS|LI|LT|LU|MK|ML|MT|MR|MC|ME|MZ|NA|NL|NZ|NE|NO|PL|PT|RO|RU|SM|RS|SK|SI|SO|ZA|ES|SD|SZ|SE|CH|TR|GB|VA|ZM|ZW) ]]; then
                validcountry=1
                languagechange=en
                echo "Country and language set to $countrychange $languagechange."
            else
                echo -n "Invalid country for this region. Please choose a valid country."
            fi
            ;;
        "TWN")
            if [[ "$countrychange" =~ ^(TW|HK) ]]; then
                validcountry=1
                languagechange=zh
                echo "Country and language set to $countrychange $languagechange."
            else
                echo -n "Invalid country for this region. Please choose a valid country."
            fi
            ;;
        *)
            echo -n "The chosen region was not found. This should not be possible."
            exit 2
            ;;
        esac
    done
else
    case "$regionchange" in
    "JPN")
        countrychange=JP
        languagechange=ja
        echo "Country and language set to $countrychange $languagechange."
        ;;
    "KOR")
        countrychange=KOR
        languagechange=ko
        echo "Country and language set to $countrychange $languagechange."
        ;;
    "CHN")
        countrychange=CHN
        languagechange=zh
        echo "Country and language set to $countrychange $languagechange."
        ;;
    *)
        echo "The chosen region was not found. This should not be possible."
        exit 2
        ;;
    esac
fi

echo "Processing..."

if cleaninty ctr EShopRegionChange --console "$latestjson" --region "$regionchange" --country "$countrychange" --language "$languagechange" | grep -q "Complete!"; then
    echo "Region change successful. No system transfer was required."
    if ! mv -f "$latestjson" ../Recipients; then
        echo "Recipients folder not found. Creating it now..."
        mkdir ../Recipients
        mv -f "$latestjson" ../Recipients
    fi
    if ! mv -f "$latestexefs" ../Recipients/exefs_archive; then
        mkdir ../Recipients/exefs_archive
        mv -f "$latestexefs" ../Recipients/exefs_archive
    fi
    exit 0
else
    printf "\n\n\n\n\n\n\n\nRegion change failed. A system transfer is required.\nChoose a donor's .json from the following list, or choose Auto to try all of them in order.\n"
    if ! cd ../Donors; then
        echo "Donors folder not found. Please obtain files from donor consoles and then try again."
        exit 1
    fi
    touch "Auto"
    select donor in *; do
        case "${donor,,}" in
        *.json)
            if cleaninty ctr LastTransfer --console "$donor" | grep -q "Ready for transfer!"; then
                if cleaninty ctr CheckReg --console "$donor" | grep -q "$jsonregion"; then
                    echo "$donor is off cooldown and has been selected."
                    donorchoice="$donor"
                    break
                else
                    echo "$donor is off cooldown, but is the wrong region. Changing automatically..."
                    if cleaninty ctr EShopRegionChange --console "$donor" --region "$jsonregion" --country "$jsoncountry" --language "$jsonlanguage" | grep -q "Complete!"; then
                        echo "Region change to $jsonregion successful. $donor has been selected."
                        donorchoice="$donor"
                        break
                    else
                        echo "Changing region failed. You should manually check whether $donor has region-locked tickets."
                        echo "Please select a different donor."
                        continue
                    fi
                fi
            else
                echo "$donor is on cooldown. Please choose a different one."
                continue
            fi
            ;;
        auto)
            donorchoice="auto"
            echo "Auto selection enabled. Checking all donors in series..."
            break
            ;;
        *)
            echo "Invalid option. Choose either a valid donor's json file or auto selection."
            continue
            ;;
        esac
    done
    rm Auto
    if [[ "$donorchoice" == auto ]]; then
        autodonorchoice="none"
        for donor in *.json; do
            if cleaninty ctr LastTransfer --console "$donor" | grep -q "Ready for transfer!"; then
                if cleaninty ctr CheckReg --console "$donor" | grep -q "$jsonregion"; then
                    echo "$donor is off cooldown and has been selected."
                    autodonorchoice="$donor"
                    break
                else
                    echo "$donor is off cooldown, but is the wrong region. Changing automatically..."
                    if cleaninty ctr EShopRegionChange --console "$donor" --region "$jsonregion" --country "$jsoncountry" --language "$jsonlanguage" | grep -q "Complete!"; then
                        echo "Region change to $jsonregion successful. $donor has been selected."
                        donorchoice="$donor"
                        break
                    else
                        echo "Changing region failed. You should manually check whether $donor has region-locked tickets."
                        echo "Moving to next donor..."
                        continue
                    fi
                fi
            else
                echo "$donor is on cooldown. Continuing..."
                continue
            fi
        done
        if [[ "$autodonorchoice" != "none" ]]; then
            cd ../Latest || exit 1
            cleaninty ctr SysTransfer --source "$latestjson" --target ../Donors/"$autodonorchoice"
            cleaninty ctr EShopRegionChange --console "$latestjson" --region "$regionchange" --country "$countrychange" --language "$languagechange"
            if ! mv -f "$latestjson" ../Recipients; then
                echo "Recipients folder not found. Creating it now..."
                mkdir ../Recipients
                mv -f "$latestjson" ../Recipients
            fi
            if ! mv -f "$latestexefs" ../Recipients/exefs_archive; then
                mkdir ../Recipients/exefs_archive
                mv -f "$latestexefs" ../Recipients/exefs_archive
            fi
            exit 0
        else
            echo "All donors are currently on cooldown. Please try again later."
            exit 2
        fi
    else
        cd ../Latest || exit 1
        if cleaninty ctr SysTransfer --source "$latestjson" --target ../Donors/"$donorchoice" | grep -q "Complete!"; then echo "System transfer successful."; else echo "System transfer from $latestjson to $donorchoice failed." && exit 2; fi
        if cleaninty ctr EShopRegionChange --console "$latestjson" --region "$regionchange" --country "$countrychange" --language "$languagechange" | grep -q "Complete!"; then echo "Region change successful."; else echo "Changing region of $latestjson failed. This should not be possible." && exit 2; fi
        if ! mv -f -t ../Recipients "$latestjson"; then
            echo "Recipients folder not found. Creating it now..."
            mkdir ../Recipients
            mv -f -t ../Recipients "$latestjson"
        fi
        if ! mv -f -t ../Recipients/exefs_archive "$latestexefs"; then
            mkdir ../Recipients/exefs_archive
            mv -f -t ../Recipients/exefs_archive "$latestexefs"
        fi
        sleep 3
        exit 0
    fi
fi
