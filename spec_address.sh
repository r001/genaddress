#!/usr/bin/env bash
#set -x
passwd=macska
result=
count=0
echo 0 > 'done'
while ! [[ "$(echo $result | egrep '0x00.{34}(.)\1{3}')" || "$(cat done)" -ne 0 ]]; do 
	count=$(( count + 1 ))
	[[ $result =~ ^0x[0-9a-fA-F]{40} ]] && curl --data "{\"method\":\"parity_killAccount\",\"params\":[\"$result\",\"$passwd\"],\"id\":1,\"jsonrpc\":\"2.0\"}" -H "Content-Type: application/json" -X POST localhost:${1:-8545} 2> /dev/null >/dev/null
	resultjson1="$(curl --data '{"method":"personal_newAccount","params":["'$passwd'"],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:${1:-8545} 2>/dev/null)"
	resultjson="$(curl --data '{"method":"personal_newAccount","params":["'$passwd'"],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST localhost:${1:-8545} 2>/dev/null)"
	result="$(echo $resultjson|jshon -e result -u)"
	[[ $result =~ ^0x00[0-9a-fA-F]{38}  ]] && printf "$count '$result'\n"
	[[ $(( $count % 500 )) -eq 0 ]] && printf "count: $count\n"
done
echo "port: ${1:-8545} address: $result" > 'done'
