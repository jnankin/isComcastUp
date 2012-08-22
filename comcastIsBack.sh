###############################
# CONFIGURATION
###############################
TWILIO_SID=""
TWILIO_AUTH_TOKEN=""
TWILIO_PHONE_NUMBER=""

PHAXIO_API_KEY=""
PHAXIO_API_SECRET=""

###############################
# ACTUAL SCRIPT
###############################
function validPhone {
	echo $1 | grep '^[[:digit:]]\{10\}$' -c
}

function comcastIsDead {
	X=`curl -sL -w "%{http_code}\\n" "http://www.google.com" -m 2 -o /dev/null`
	echo $X
}

if [ $(comcastIsDead) -gt 0 ]; then
	echo "Everything seems fine to me.  Internet is working!"
	#exit
fi

printf "Preferred method(s) of contact (any of [email,phone,sms,fax]): "
read -e CONTACT_METHODS

if [[ $CONTACT_METHODS =~ .*phone.* ]]; then
	while [ $(validPhone $PHONE_NUMBER) -eq 0 ]; do
		printf "Enter your number for phone (10-digits only): "
		read -e PHONE_NUMBER
	
		if [ $(validPhone $PHONE_NUMBER) -eq 0 ]; then
			echo That is not a valid phone number.  Try again.
			echo
			echo
		fi
	done
fi

if [[ $CONTACT_METHODS =~ .*sms.* ]]; then
	while [ $(validPhone $SMS_NUMBER) -eq 0 ]; do
		printf "Enter your number for sms (10-digits only): "
		read -e SMS_NUMBER
	
		if [ $(validPhone $SMS_NUMBER) -eq 0 ]; then
			echo That is not a valid phone number.  Try again.
			echo
			echo
		fi
	done
fi

if [[ $CONTACT_METHODS =~ .*fax.* ]]; then
	while [ $(validPhone $FAX_NUMBER) -eq 0 ]; do
		printf "Enter your number for fax (10-digits only): "
		read -e FAX_NUMBER
	
		if [ $(validPhone $FAX_NUMBER) -eq 0 ]; then
			echo That is not a valid phone number.  Try again.
			echo
			echo
		fi
	done
fi

if [[ $CONTACT_METHODS =~ .*email.* ]]; then
	printf "Enter your email address: "
	read -e EMAIL
fi

while [ $(comcastIsDead) -eq 0 ]; do
	echo Trying internet...
done

echo COMCAST IS BACK BABY!

if [[ $CONTACT_METHODS =~ .*phone.* ]]; then
echo calling phone...
curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_SID/Calls.json" \
-d "From=$TWILIO_PHONE_NUMBER" \
-d "To=$PHONE_NUMBER" \
-d 'Url=http%3A%2F%2Fjnankin.comuv.com%2Fsay.xml' \
-u $TWILIO_SID:$TWILIO_AUTH_TOKEN > /dev/null
fi

if [[ $CONTACT_METHODS =~ .*sms.* ]]; then
echo sending sms...
curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_SID/SMS/Messages.xml" \
-d "To=$SMS_NUMBER" \
-d "From=$TWILIO_PHONE_NUMBER" \
-d 'Body=Comcast+is+back!+Its+about+time!' \
-u $TWILIO_SID:$TWILIO_AUTH_TOKEN  > /dev/null
fi

if [[ $CONTACT_METHODS =~ .*fax.* ]]; then
echo sending fax...
curl -s https://api.phaxio.com/v1/send \
-F "to=$FAX_NUMBER" \
-F "string_data=\<h1>Comcast is back"'!'" It's about time"'!'"</h1>" \
-F 'string_data_type=html' \
-F "api_key=$PHAXIO_API_KEY" \
-F "api_secret=$PHAXIO_API_SECRET" > /dev/null
fi

if [[ $CONTACT_METHODS =~ .*email.* ]]; then
	echo sending email...
	 mail -s 'Comcast is back!  Its about time!' $EMAIL < /dev/null
fi
