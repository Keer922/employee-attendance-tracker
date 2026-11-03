
#!/bin/bash

while true
do
    echo ""
    echo "      EMPLOYEE ATTENDANCE TRACKER"
    echo "1. Add Attendance"
    echo "2. View Attendance"
    echo "3. Track Working Hours and Late Arrivals"
    echo "4. Payroll Report"
    echo "5. Attendance Reports"
    echo "6. Detect Attendance Anomalies"
    echo "0. Exit"

    read -r -p "Enter your choice: " choice

    case $choice in
        1)
            bash attendance.sh add
            ;;
        2)
            bash attendance.sh view
            ;;
        3)
            bash time_tracking.sh
            ;;
        4)
            bash payroll.sh
            ;;
        5)
            bash reports.sh
            ;;
        6)
            bash anomaly_detector.sh
            ;;
        0)
            echo "Thank you for using the Attendance Tracker!"
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

