
#!/bin/bash

# Employee Attendance Tracker
# Member 1 - Add and View Attendance

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA_FILE="$SCRIPT_DIR/attendance.csv" 

# Create CSV file with header if it doesn't exist or is empty
if [ ! -s "$DATA_FILE" ]; then
    echo "EmployeeID,Date,CheckIn,CheckOut" > "$DATA_FILE"
fi


# Function to add attendance
add_attendance() {

    echo "===== Add Attendance ====="

    read -r -p "Enter Employee ID: " employee_id
    read -r -p "Enter Date (YYYY-MM-DD): " date
    read -r -p "Enter Check-in Time (HH:MM): " check_in
    read -r -p "Enter Check-out Time (HH:MM): " check_out

    # Check for empty fields
    if [[ -z "$employee_id" || -z "$date" || -z "$check_in" || -z "$check_out" ]]; then
        echo "Error: All fields are required!"
        return 1
    fi

    # Validate Employee ID
    if [[ ! "$employee_id" =~ ^[A-Za-z0-9]+$ ]]; then
        echo "Error: Invalid Employee ID!"
        return 1
    fi

    # Validate date
    if [[ ! "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || \
       ! date -d "$date" >/dev/null 2>&1 || \
       [[ "$(date -d "$date" +%F)" != "$date" ]]; then
        echo "Error: Invalid date! Use YYYY-MM-DD."
        return 1
    fi

    # Validate check-in time
    if [[ ! "$check_in" =~ ^([0-9]|[01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "Error: Invalid check-in time! Use H:MM or HH:MM."
        return 1
    fi

    # Convert check-in time to HH:MM format
    check_in=$(date -d "$check_in" +%H:%M)

    # Validate check-out time
    if [[ ! "$check_out" =~ ^([0-9]|[01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "Error: Invalid check-out time! Use H:MM or HH:MM."
        return 1
    fi

    # Convert check-out time to HH:MM format
    check_out=$(date -d "$check_out" +%H:%M)

    # Check whether check-out is after check-in
    # Overnight shifts are allowed
    if [[ "$check_out" == "$check_in" ]]; then
        echo "Error: Check-out time cannot be the same as check-in time!"
        return 1
    fi

    # Check for duplicate attendance
if awk -F',' -v id="$employee_id" -v d="$date" \
    'NR > 1 && $1 == id && $2 == d { found=1 }
     END { exit !found }' "$DATA_FILE"; then

    echo "Error: Attendance already exists for this employee on this date!"
    return 1
fi

    # Save attendance record
    echo "$employee_id,$date,$check_in,$check_out" >> "$DATA_FILE"

    echo "Attendance added successfully!"
}


# Function to view attendance
view_attendance() {

    echo "===== Employee Attendance Records ====="

    if [ ! -s "$DATA_FILE" ] || [ "$(wc -l < "$DATA_FILE")" -le 1 ]; then
        echo "No attendance records found."
    else
        column -s ',' -t "$DATA_FILE"
    fi
}


# Execute the selected operation
case "$1" in
    add)
        add_attendance
        ;;
    view)
        view_attendance
        ;;
    *)
        echo "Usage: bash attendance.sh {add|view}"
        ;;
esac
