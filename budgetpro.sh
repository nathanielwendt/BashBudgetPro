#!/bin/bash


#while true; do
#	read -p "Would you like to exit budgetpro?" input
#	case $input in
#		[Yy]* ) echo "still in program"; break;;
#		[Nn]* ) exit;;
#		* ) echo "Please answer yes or no.";;
#	esac
#done

readFromFile() {
	content=$(<budget_data.txt)
	content_arr=$(echo $content | tr "," " ")

	i=0;
	heading_count=0;
	for x in $content_arr
	do
		if (( (i < 14) && (i % 7) )); then
			x=$(expandDecimal $x)
		#	past[i]=$x
			current[i]=$x
		elif (( (i >= 14) && (i % 7) )); then
			x=$(expandDecimal $x)
			past[i]=$x
		else
			headings[heading_count]=$x
			heading_count=`expr $heading_count + 1`
		fi
			
		i=`expr $i + 1`
	done
}

backupFile(){
	cp budget_data.txt budgetProBackup/"$(date +%F--%T)"_data.txt 
}

arrayToFile(){
	declare -a argAry1=("${!1}")
	i=0;
	outStr=""
	for x in ${argAry1[@]}
	do
		if ! (( (i % 7) )); then
			index=$((i/7 + $2))
			outStr+=${headings[$index]}","
			i=`expr $i + 1`
		fi
		outStr+="$(contractDecimal $x),"
		i=`expr $i + 1`
		if (( !(i % 7) && (i != 0) )); then
			echo $outStr >> budget_data.txt
			outStr=""
		fi
	done
	echo -n $outStr >> budget_data.txt
}


writeToFile(){
	backupFile
	rm budget_data.txt
	#echo "" > tester.txt #overwrites file
	arrayToFile current[@] 0
	arrayToFile past[@] 2

}

#get return val by casting result like val=$(expandDecimal 1 2)
expandDecimal(){
	IFS="." read -a vals <<< "$1"
	if ! [ -z "${vals[0]}" ]; then
		let temp=${vals[0]}*100
	else
		let temp=0
	fi
	safeDec=$(expr ${vals[1]} + 0)
	returnVal=$(($temp + $safeDec))
    	echo "$returnVal"
}

getDollars(){
	param=$1
	let length=${#param}
	if ((length <= 3)); then  #this means there is only a decimal, no dollar portion
		echo "0"
		return
	fi
	let backend=$length-2
	let dollars=${1:0:$backend}
	echo $dollars
}

getDecimal(){
	param=$1
	length=${#param}
	let backend=$length-2
	
	#decimal=`echo ${1:$backend:$length} | sed 's/^0*//'`
	decimal=${1:$backend:$length}
	res_len=${#decimal}
	#if(( res_len > 1 )); then
	#	echo "$0{decimal}"
	#else
	#	echo "${decimal}"
	#fi
	echo $decimal
}

contractDecimal(){
	if (($1 != 0)); then
		echo $(getDollars $1).$(getDecimal $1)
	else
		echo "0.00"
	fi
}

 
#contractDecimal 0
#expandDecimal 100.21
#expandDecimal 100.03
#expandDecimal 100.40
#getDecimal 10009
#getDecimal 10021
#getDecimal 10030
#getDecimal 10050

printBalances(){
	grocery[0]="$(contractDecimal ${current[1]})"
	grocery[1]="$(contractDecimal ${current[8]})"
	utilities[0]="$(contractDecimal ${current[2]})"
	utilities[1]="$(contractDecimal ${current[9]})"
	internettv[0]="$(contractDecimal ${current[3]})"
	internettv[1]="$(contractDecimal ${current[10]})"
	tier1save[0]="$(contractDecimal ${current[4]})"
	tier1save[1]="$(contractDecimal ${current[11]})"
	tier2save[0]="$(contractDecimal ${current[5]})"
	tier2save[1]="$(contractDecimal ${current[12]})"
	spending[0]="$(contractDecimal ${current[6]})"
	spending[1]="$(contractDecimal ${current[13]})"
	
	echo -e "\n"
	echo -e "\n"
	echo "Month: ${current[0]}"
	echo "----------------------------"
	echo "Category    Left   Allocated"
	echo "----------------------------"
	echo "Grocery     ${grocery[0]}     ${grocery[1]}"
	echo "Utilities   ${utilities[0]}     ${utilities[1]}"
	echo "Internet/TV ${internettv[0]}     ${internettv[1]}"
	echo "Tier1 Save  ${tier1save[0]}     ${tier1save[1]}"
	echo "Tier2 Save  ${tier2save[0]}     ${tier2save[1]}"
	echo "Spending    ${spending[0]}     ${spending[1]}"
	echo -e "\n"
}

addExpense(){
	case $1 in
		("grocery"* ) current[1]=`expr ${current[1]} - $(expandDecimal $2)`;;
		("utilities"* ) current[2]=`expr ${current[2]} - $(expandDecimal $2)`;;
		("internet"* ) current[3]=`expr ${current[3]} - $(expandDecimal $2)`;;
		("tier1"* ) current[4]=`expr ${current[4]} - $(expandDecimal $2)`;;
		("tier2"* ) current[5]=`expr ${current[5]} - $(expandDecimal $2)`;;
		("spending"* ) current[6]=`expr ${current[6]} - $(expandDecimal $2)`;;
		* ) echo "Error, syntax should be: expense [account] [amount]"
	    	return;;
	esac
}

transfer(){
	if [[ -z "$3" ]]; then
		echo "Error, syntax should be: transfer [account1] [account2] [amount]"
		return
	else
		addExpense $1 $3
		addExpense $2 $(($3*-1))
	fi
}

readFromFile
input=""
while [[ $input != "exit" ]]; do
	input_args[1]=""
	input_args[2]=""
	read -p "BudgetPro >> " input
	i=0
	for x in $input
	do
		input_args[i]=$x	
		i=`expr $i + 1`
	done

	case $input in
		("view balances") printBalances;;
		("save") writeToFile;;
		("expense"* ) addExpense ${input_args[1]} ${input_args[2]};;
		("transfer"* ) transfer ${input_args[1]} ${input_args[2]} ${input_args[3]};;
		("new month") echo "new month";;
		("exit") ;;
		* ) echo "not a valid command. type help if needed";;
	esac
done


#getInput "Would you like to exit?" Yy Nn 
