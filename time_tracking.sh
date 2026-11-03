#!/bin/bash


SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"


DATA_FILE="$SCRIPT_DIR/attendance.csv"


if [[ ! -f "$DATA_FILE" ]]; then
    echo "Error: Attendance file not found!"
    exit 1
fi

echo "============== EMPLOYEE TIME TRACKING =============="


printf "%-12s %-12s %-12s %-12s %-10s %-12s %-10s\n" \
"EmployeeID" "Date" "CheckIn" "CheckOut" "Hours" "Status" "ShiftAlert"

echo "---------------------------------------------------------------------------------------------"


awk -F',' '
NR > 1 {


    for (i = 1; i <= 4; i++) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)
    }


    if ($3 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/) {
        printf "%-12s %-12s %-12s %-12s %-10s %-12s %-10s\n",
        $1, $2, $3, $4, "INVALID", "INVALID", "-"
        next
    }


    split($3, start, ":")
    start_time = start[1] * 60 + start[2]


    if (start_time > 555) {
        status = "LATE"
    }
    else {
        status = "ON TIME"
    }

    if ($4 == "" || $4 == "-") {
        printf "%-12s %-12s %-12s %-12s %-10s %-12s %-10s\n",
        $1, $2, $3, "-", "PENDING", status, "-"
        next
    }


    if ($4 !~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/) {
        printf "%-12s %-12s %-12s %-12s %-10s %-12s %-10s\n",
        $1, $2, $3, $4, "INVALID", status, "-"
        next
    }


    split($4, finish, ":")
    end_time = finish[1] * 60 + finish[2]


    if (end_time < start_time) {
        end_time = end_time + 1440
    }


    total_minutes = end_time - start_time

    if (total_minutes == 0) {
        result = "INVALID"
        alert = "-"
    }
    else {
        hours = total_minutes / 60
        result = sprintf("%.2f", hours)

        if (hours > 12) {
            alert = "LONG SHIFT"
        }
        else {
            alert = "-"
        }
    }

    printf "%-12s %-12s %-12s %-12s %-10s %-12s %-10s\n",
    $1, $2, $3, $4, result, status, alert
}

' "$DATA_FILE"

echo "---------------------------------------------------------------------------------------------"
echo "Time tracking completed!"

