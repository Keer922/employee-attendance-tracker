#!/bin/bash

# Employee Attendance Tracker
# Member 3 - Payroll and Overtime

FILE="attendance.csv"

HOURLY_RATE=150
STANDARD_HOURS=8
OVERTIME_MULTIPLIER=1.5

if [ ! -f "$FILE" ]; then
    echo "Error: attendance.csv not found!"
    exit 1
fi

echo "             EMPLOYEE PAYROLL REPORT"
echo "Hourly Rate: Rs. $HOURLY_RATE"
echo "Standard Hours: $STANDARD_HOURS"
echo "Overtime Rate: ${OVERTIME_MULTIPLIER}x hourly rate"
echo

awk -F, -v rate="$HOURLY_RATE" \
    -v standard="$STANDARD_HOURS" \
    -v multiplier="$OVERTIME_MULTIPLIER" '

BEGIN {
    printf "%-8s %-12s %-8s %-8s %-8s %-12s %-12s %-12s\n",
           "Employee", "Date", "Hours", "Regular", "OT",
           "RegularPay", "OvertimePay", "TotalPay"
    print "--------------------------------------------------------------------------------"
}

NR == 1 {
    next
}

NF == 0 {
    next
}

{
    if (NF != 4 || $1 == "" || $2 == "") {
        skipped++
        next
    }

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

    hours = (finish - start) / 60

    regular = hours
    if (regular > standard)
        regular = standard

    overtime = hours - regular

    regular_pay = regular * rate
    overtime_pay = overtime * rate * multiplier

    salary = regular_pay + overtime_pay

    total_regular += regular
    total_overtime += overtime
    total_regular_pay += regular_pay
    total_overtime_pay += overtime_pay
    total_payroll += salary

    processed++

    printf "%-8s %-12s %-8.2f %-8.2f %-8.2f Rs.%-9.2f Rs.%-9.2f Rs.%-9.2f\n",
           $1, $2, hours, regular, overtime,
           regular_pay, overtime_pay, salary
}

END {
    print "--------------------------------------------------------------------------------"
    printf "Records processed: %d\n", processed
    printf "Records excluded: %d\n", skipped
    printf "Total regular hours: %.2f\n", total_regular
    printf "Total overtime hours: %.2f\n", total_overtime
    printf "Total regular pay: Rs. %.2f\n", total_regular_pay
    printf "Total overtime pay: Rs. %.2f\n", total_overtime_pay
    printf "Total payroll: Rs. %.2f\n", total_payroll
}

' "$FILE"

echo
echo "             PAYROLL COMPLETE"
