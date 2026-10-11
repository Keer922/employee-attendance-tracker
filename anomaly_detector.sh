#!/bin/bash
FILE="attendance.csv"

if [ ! -f "$FILE" ]; then
    echo "Error: attendance.csv not found!"
    exit 1
fi

echo "       ATTENDANCE ANOMALY SCAN"

awk -F, '
NR == 1 { next }

{
    emp = $1
    date = $2
    checkin = $3
    checkout = $4
    problem = ""

    # Check required fields
    if (emp == "" || date == "" || checkin == "") {
        problem = "Missing required information"
    }

    # Check date format
    else if (date !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
        problem = "Invalid date format"
    }

    # Check check-in format
    else if (checkin !~ /^[0-9]{2}:[0-9]{2}$/) {
        problem = "Invalid check-in format"
    }

    # Check checkout format when present
    else if (checkout != "" && checkout !~ /^[0-9]{2}:[0-9]{2}$/) {
        problem = "Invalid checkout format"
    }

    else {
        split(checkin, a, ":")
        start = a[1] * 60 + a[2]

        if (a[1] > 23 || a[2] > 59) {
            problem = "Invalid check-in time"
        }

        else if (checkout != "") {
            split(checkout, b, ":")
            finish = b[1] * 60 + b[2]

            if (b[1] > 23 || b[2] > 59) {
                problem = "Invalid checkout time"
            }
            else if (finish < start) {
                problem = "Checkout is before check-in"
            }
            else if (finish - start > 720) {
                problem = "Shift exceeds 12 hours"
            }
        }
    }

    # Check duplicate employee/date records
    key = emp "," date

    if (emp != "" && date != "" && seen[key]++) {
        print "WARNING:", emp, "|", date, "| Duplicate attendance record"
    }

    if (problem != "") {
        print "WARNING:", emp, "|", date, "|", problem
        issues++
    }

    if (problem != "" || (checkout != "" &&
        checkout ~ /^[0-9]{2}:[0-9]{2}$/ &&
        checkin ~ /^[0-9]{2}:[0-9]{2}$/ &&
        finish >= start && finish - start > 720)) {
        total++
    }
}

END {
    print ""
    print "Records with detected problems:", total
    if (total == 0)
        print "No anomalies detected."
    print "Scan finished."
}
' "$FILE"
