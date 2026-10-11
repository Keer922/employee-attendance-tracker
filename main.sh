#!/bin/bash
while true
do
    echo ""
    echo "      EMPLOYEE ATTENDANCE TRACKER"
    echo "1. View Attendance"
    echo "2. Track Working Hours and Late Arrivals"
    echo "3. Payroll Report"
    echo "4. Attendance Reports"
    echo "5. Detect Attendance Anomalies"
    echo "0. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            bash attendance.sh
            ;;
        2)
            bash time_tracking.sh
            ;;
        3)
            bash payroll.sh
            ;;
        4)
            bash reports.sh
            ;;
        5)
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
