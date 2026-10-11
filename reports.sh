#!/bin/bash

FILE="attendance.csv"

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
    records++
    employees[$1] = 1
    if ($3 > "09:15") late++
    if ($4 == "") missing++
}
END {
    for (e in employees) total++
    print "Total attendance records:", records
    print "Total employees:", total
    print "Late arrivals:", late
    print "Missing checkouts:", missing
}' "$FILE"

echo ""
echo "2. LATE ARRIVALS (After 09:15 AM)"
awk -F, 'NR > 1 && $3 > "09:15" {
    print $1, "|", $2, "| Check-in:", $3
}' "$FILE"

echo ""
echo "3. EMPLOYEES WHO STAYED LONGER THAN 8 HOURS"
awk -F, '
NR > 1 && $3 ~ /^[0-9][0-9]:[0-9][0-9]$/ &&
$4 ~ /^[0-9][0-9]:[0-9][0-9]$/ {
    split($3,a,":")
    split($4,b,":")
    start = a[1]*60 + a[2]
    finish = b[1]*60 + b[2]
    if (finish >= start && finish-start > 480)
        printf "%s | %s | Hours worked: %.2f\n", $1, $2, (finish-start)/60
}' "$FILE"

echo ""
echo "4. EARLY CHECKOUTS (Before 05:00 PM)"
awk -F, 'NR > 1 && $4 != "" && $4 < "17:00" {
    print $1, "|", $2, "| Check-out:", $4
}' "$FILE"

echo ""
echo "5. SHORT SHIFTS (Less than 6 hours)"
awk -F, '
NR > 1 && $3 ~ /^[0-9][0-9]:[0-9][0-9]$/ &&
$4 ~ /^[0-9][0-9]:[0-9][0-9]$/ {
    split($3,a,":")
    split($4,b,":")
    start = a[1]*60 + a[2]
    finish = b[1]*60 + b[2]
    if (finish >= start && finish-start < 360)
        printf "%s | %s | Hours worked: %.2f\n", $1, $2, (finish-start)/60
}' "$FILE"

echo ""
echo "6. MISSING CHECKOUTS"
awk -F, 'NR > 1 && $4 == "" {
    print $1, "|", $2, "| Checkout not recorded"
}' "$FILE"

echo ""
echo "          REPORT COMPLETE"
