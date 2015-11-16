#!/usr/bin/python
#
# This script uses the hpilo module to read
# the Ilo server event log for any critical errors
# that happened within the last 7 days
# If there are any errors it will put them into an array
# and print out the latest error
# This is then used to pass on to zabbix for monitoring
# and alerting
#

# import the neccesary modules
import hpilo
import sys
from datetime import datetime
from datetime import timedelta

try:
	# specify which ilo host to query
	ilo = hpilo.Ilo("localhost")
 	errors = []
 	total = []

	# if the ilo log is empty this list is returned as a basically empty dict instead
	# so here we test for that and exit
	if isinstance(ilo.get_server_event_log(), dict):
		sys.exit("iLo log is empty")

        # search for critical errors within the last 7 days
	for event in ilo.get_server_event_log():
		# here we need to skip events that don't have a proper time set (Yes, the extra whitespace is needed)
		if event['initial_update'] == '[NOT SET] ':
				continue
  		if event['severity'] == 'Critical' and datetime.strptime(event['initial_update'], '%m/%d/%Y %H:%M') > (datetime.now() - timedelta(days=7)):
        		total.append(event['description'])

        # test for a non empty list, and if so print out the most recent error. Otherwise, we didn't find any errors
	if total:
  	  print "PROBLEM: %s" % (total[-1])
	if not total:
          print "HEALTHY"

# Catch common exceptions here
except ValueError:
    print "Error: Invalid value"
except ExpatError:
    print "Error: Expat error"
except AttributeError:
	print "Error: attribute error"
except hpilo.IloError:
	print "Error: unable to communicate with iLO"
