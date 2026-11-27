#!/bin/bash

# Employee Attendance Tracker

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FILE="$SCRIPT_DIR/attendance.csv"

if [ ! -f "$FILE" ]; then
    echo "Error: attendance.csv not found!"
    exit 1
fi

echo "       EMPLOYEE ATTENDANCE REPORT"

date
echo ""

echo "1. GENERAL SUMMARY"

awk -F, '
NR > 1 {
    for (i = 1; i <= NF; i++) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)
    }

    if (NF != 4 || $1 == "" || $2 == "")
        next

    records++
    employees[$1] = 1

    if ($3 ~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/) {
        split($3, a, ":")
        checkin = a[1]*60 + a[2]

        if (checkin > 555)
            late++
    }

    if ($4 == "" || $4 == "-")
        missing++
}

END {
    for (e in employees)
        total++

    print "Total attendance records:", records
    print "Total employees:", total
    print "Late arrivals:", late
    print "Missing checkouts:", missing
}' "$FILE"

echo ""
echo "2. LATE ARRIVALS (After 09:15 AM)"

awk -F, '
NR > 1 {
    for (i = 1; i <= NF; i++)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)

    if (NF != 4 || $1 == "" || $2 == "")
        next

    if ($3 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/)
        next

    split($3, a, ":")
    checkin = a[1]*60 + a[2]

    if (checkin > 555)
        print $1, "|", $2, "| Check-in:", $3
}' "$FILE"

echo ""
echo "3. OVERTIME (More than 8 hours)"

awk -F, '
NR > 1 {
    for (i = 1; i <= NF; i++)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)

    if (NF != 4 || $1 == "" || $2 == "")
        next

    if ($3 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/ ||
        $4 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/)
        next

    split($3, a, ":")
    split($4, b, ":")

    start = a[1]*60 + a[2]
    finish = b[1]*60 + b[2]

    if (finish <= start)
        next

    hours = (finish-start)/60

    if (hours > 8) {
        printf "%s | %s | Hours: %.2f\n",
        $1, $2, hours
    }
}' "$FILE"

echo ""
echo "4. EARLY CHECKOUTS (Before 05:00 PM)"

awk -F, '
NR > 1 {
    for (i = 1; i <= NF; i++)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)

    if (NF != 4 || $1 == "" || $2 == "")
        next

    if ($3 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/ ||
        $4 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/)
        next

    split($3, a, ":")
    split($4, b, ":")

    start = a[1]*60 + a[2]
    finish = b[1]*60 + b[2]

    if (finish > start && finish < 1020)
        print $1, "|", $2, "| Check-out:", $4
}' "$FILE"

echo ""
echo "5. SHORT SHIFTS (Less than 6 hours)"

awk -F, '
NR > 1 {
    for (i = 1; i <= NF; i++)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)

    if (NF != 4 || $1 == "" || $2 == "")
        next

    if ($3 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/ ||
        $4 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/)
        next

    split($3, a, ":")
    split($4, b, ":")

    start = a[1]*60 + a[2]
    finish = b[1]*60 + b[2]

    if (finish > start && finish-start < 360) {
        printf "%s | %s | Hours: %.2f\n",
        $1, $2, (finish-start)/60
    }
}' "$FILE"

echo ""
echo "6. MISSING CHECKOUTS"

awk -F, '
NR > 1 {
    for (i = 1; i <= NF; i++)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)

    if (NF == 4 && $1 != "" && $2 != "" &&
        ($4 == "" || $4 == "-")) {
        print $1, "|", $2, "| Checkout not recorded"
    }
}' "$FILE"

echo ""
echo "          REPORT COMPLETE"
