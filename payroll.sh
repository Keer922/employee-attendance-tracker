#!/bin/bash

# Employee Attendance Tracker
# Member 3 - Payroll and Overtime

FILE="attendance.csv"

HOURLY_RATE=150
STANDARD_HOURS=8

if [ ! -f "$FILE" ]; then
    echo "Error: attendance.csv not found!"
    exit 1
fi

echo "             EMPLOYEE PAYROLL REPORT"

awk -F, -v rate="$HOURLY_RATE" -v standard="$STANDARD_HOURS" '

BEGIN {
    printf "%-10s %-12s %-10s %-10s %-12s\n",
           "Employee", "Date", "Hours", "Overtime", "Salary"
    print "----------------------------------------------------------"
}

NR == 1 {
    next
}

{
    if ($3 == "" || $4 == "") {
        skipped++
        next
    }

    if ($3 !~ /^[0-9][0-9]:[0-9][0-9]$/ ||
        $4 !~ /^[0-9][0-9]:[0-9][0-9]$/) {
        skipped++
        next
    }

    split($3, a, ":")
    split($4, b, ":")

    start = a[1]*60 + a[2]
    finish = b[1]*60 + b[2]

    if (a[1] > 23 || b[1] > 23 ||
        a[2] > 59 || b[2] > 59 ||
        finish <= start) {
        skipped++
        next
    }

    hours = (finish-start)/60

    regular = hours
    if (regular > standard)
        regular = standard

    overtime = hours - regular

    salary = (regular * rate) + (overtime * rate)

    total_payroll += salary
    total_overtime += overtime
    processed++

    printf "%-10s %-12s %-10.2f %-10.2f Rs. %-10.2f\n",
           $1, $2, hours, overtime, salary
}

END {
    print "----------------------------------------------------------"
    printf "Records processed: %d\n", processed
    printf "Records excluded: %d\n", skipped
    printf "Total overtime hours: %.2f\n", total_overtime
    printf "Total payroll: Rs. %.2f\n", total_payroll
}

' "$FILE"

echo "             PAYROLL COMPLETE"
