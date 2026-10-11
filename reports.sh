#!/bin/bash

FILE="attendance.csv"

if [ ! -f "$FILE" ]; then
    echo "attendance.csv not found!"
    exit 1
fi

while true
do
    echo ""
    echo "ATTENDANCE REPORTS"
    echo "1. Monthly Attendance Report"
    echo "2. Employee Report"
    echo "3. Late Arrival Report"
    echo "4. Early Checkout Report"
    echo "5. Short Shift Report"
    echo "6. Missing Checkout Report"
    echo "0. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter month (YYYY-MM): " month
            echo "Monthly Attendance Report"
            echo "-------------------------"
            grep "$month" "$FILE" | awk -F, '
            {
                records++
                employees[$1]=1
                if ($3 > "09:15") late++
                if ($4 == "") missing++
                if ($4 != "" && $4 < "17:00") early++
            }
            END {
                for (e in employees) count++
                print "Attendance records:", records
                print "Employees:", count
                print "Late arrivals:", late
                print "Early checkouts:", early
                print "Missing checkouts:", missing
            }'
            ;;

        2)
            read -p "Enter Employee ID: " emp
            echo "Attendance for $emp"
            grep "^$emp," "$FILE" | sed 's/,/  |  /g'
            ;;

        3)
            read -p "Enter month (YYYY-MM): " month
            echo "Late Arrivals"
            grep "$month" "$FILE" | awk -F, '$3 > "09:15" {
                print $1, $2, "Check-in:", $3
            }'
            ;;

        4)
            read -p "Enter month (YYYY-MM): " month
            echo "Early Checkouts"
            grep "$month" "$FILE" | awk -F, '$4 != "" && $4 < "17:00" {
                print $1, $2, "Check-out:", $4
            }'
            ;;

        5)
            read -p "Enter month (YYYY-MM): " month
            echo "Short Shifts (less than 6 hours)"
            grep "$month" "$FILE" | awk -F, '
            $3 ~ /^[0-9][0-9]:[0-9][0-9]$/ &&
            $4 ~ /^[0-9][0-9]:[0-9][0-9]$/ {
                split($3,a,":")
                split($4,b,":")
                start=a[1]*60+a[2]
                finish=b[1]*60+b[2]
                if (finish >= start && finish-start < 360)
                    print $1, $2, "Hours:", (finish-start)/60
            }'
            ;;

        6)
            read -p "Enter month (YYYY-MM): " month
            echo "Missing Checkouts"
            grep "$month" "$FILE" | awk -F, '$4 == "" {
                print $1, $2, "No checkout recorded"
            }'
            ;;

        0)
            echo "Exiting reports."
            break
            ;;

        *)
            echo "Invalid choice. Try again."
            ;;
    esac
done
