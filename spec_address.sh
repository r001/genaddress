#!/usr/bin/env bash
#set -x
for ((i=0;i<20;i++)); 
do 
	passwd=macska
	address=
	count=0
	echo 0 > 'done'
	while ! [[ "$(echo $address | egrep '0x000.{33}(0)\1{2}[b]')" ]] && [[ "$(cat done)" -eq 0 ]] 2>/dev/null; do 
		count=$(( count + 1 ))
		resultjson="$(curl --data '{"method":"parity_generateSecretPhrase","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:${1:-8545} 2>/dev/null)"
		export phrase="$(echo $resultjson|jshon -e result -u)"
		resultjson1=`curl --data "{\"method\":\"parity_phraseToAddress\",\"params\":[\"$phrase\"],\"id\":1,\"jsonrpc\":\"2.0\"}" -H "Content-Type: application/json" -X POST localhost:${1:-8545} 2>/dev/null`
		address="$(echo $resultjson1|jshon -e result -u)"
		[[ $address =~ ^0x00[0-9a-fA-F]{38}  ]] && printf "$count '$address'\n"
		[[ $(( $count % 500 )) -eq 0 ]] && printf "count: $count\n"
	done
	sleep 2
	if [[ "$(cat done)" -eq 0 ]] 2>/dev/null; then
		resultjson2=`curl --data "{\"method\":\"parity_newAccountFromPhrase\",\"params\":[\"$phrase\",\"$passwd\"],\"id\":1,\"jsonrpc\":\"2.0\"}" -H "Content-Type: application/json" -X POST localhost:${1:-8545} 2>/dev/null`
		echo "$phrase" > "$address"
		gpg --output "$address.gpg" --encrypt --recipient rob@nyar.eu "$address"
		rm "$address"
		echo "port: ${1:-8545} address: $address" > 'done'
	fi
	sleep 4
done
