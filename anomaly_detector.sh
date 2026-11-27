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

    if (emp == "" || date == "" || checkin == "") {
        problem = "Missing required information"
    }
    else if (date !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
        problem = "Invalid date format"
    }
    else if (checkin !~ /^[0-9][0-9]:[0-9][0-9]$/) {
        problem = "Invalid check-in format"
    }
    else if (checkout == "") {
        problem = "Missing checkout"
    }
    else if (checkout !~ /^[0-9][0-9]:[0-9][0-9]$/) {
        problem = "Invalid checkout format"
    }
    else {
        split(checkin, a, ":")
        split(checkout, b, ":")

        start = a[1]*60+a[2]
        finish = b[1]*60+b[2]

        if (a[1] > 23 || a[2] > 59)
            problem = "Invalid check-in time"
        else if (b[1] > 23 || b[2] > 59)
            problem = "Invalid checkout time"
        else if (finish < start)
            problem = "Checkout before check-in"
        else if (finish-start > 720)
            problem = "Shift exceeds 12 hours"
    }

    key = emp "," date

    if (emp != "" && date != "" && seen[key]++) {
        print "WARNING:", emp, "|", date, "| Duplicate record"
        total++
    }

    if (problem != "") {
        print "WARNING:", emp, "|", date, "|", problem
        total++
    }
}

END {
    print ""
    print "Total detected problems:", total

    if (total == 0)
        print "No anomalies detected."

    print "Scan complete."
}
' "$FILE"
```
