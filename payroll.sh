#!/bin/bash

# Employee Attendance Tracker
# Module: Payroll and Overtime

CSV_FILE="attendance.csv"

HOURLY_RATE=150
STANDARD_HOURS=8
OVERTIME_RATE=150

generate_payroll() {

    if [ ! -f "$CSV_FILE" ]; then
        echo "Attendance file not found!"
        return 1
    fi

    echo "=========================================="
    echo "          EMPLOYEE PAYROLL REPORT"
    echo "=========================================="

    awk -F',' -v rate="$HOURLY_RATE" \
        -v standard="$STANDARD_HOURS" \
        -v ot_rate="$OVERTIME_RATE" '

    BEGIN {
        printf "%-10s %-10s %-10s %-10s %-10s\n",
               "Employee", "Hours", "Regular", "Overtime", "Salary"
        total = 0
    }

    NR == 1 { next }

    {
        if ($2 == "" || $3 == "" || $4 == "")
            next

        split($3, start, ":")
        split($4, finish, ":")

        start_time = start[1] * 60 + start[2]
        end_time = finish[1] * 60 + finish[2]

        if (start_time < 0 || start_time >= 1440 ||
            end_time < 0 || end_time >= 1440 ||
            start[2] < 0 || start[2] > 59 ||
            finish[2] < 0 || finish[2] > 59 ||
            end_time <= start_time)
            next

        hours = (end_time - start_time) / 60
        hours = sprintf("%.2f", hours)

        regular = (hours < standard) ? hours : standard

        overtime = (hours > standard) ? hours - standard : 0

        salary = (regular * rate) + (overtime * ot_rate)

        total += salary

        printf "%-10s %-10.2f %-10.2f %-10.2f Rs. %.2f\n",
               $1, hours, regular, overtime, salary
    }

    END {
        printf "\nTotal Payroll: Rs. %.2f\n", total
    }

    ' "$CSV_FILE"

    echo "=========================================="
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    generate_payroll
fi
