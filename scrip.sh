#!/bin/bash
# Вольняга Максим ИУ7-16Б (ВАР-2)

# Выход из скрипта, если пользователь - админ 
if [[ $UID == 0 ]]; then
	echo "Вы зашли под админом, вход запрещен"
	exit
fi 

work_dir=$(dirname "$0") # Расположение скрипта
cd $work_dir # Изменяю положение пользователя

config_temp="*.log"
config_work="*.py"
config_work_dir="./"
config_programm="grep def* program.py >last.log"

# Массив содержащий конфигурации по умолчанию 
config=( "$config_temp" "$config_work" "$config_work_dir" "$config_programm" ) 		
config_now=("${config[@]}")		# Текущая конфигурация

# Запись конфигурации в con.myconfig
config_rec(){
	IFS_OLD=$IFS
	IFS=""
	echo -n > ./con.myconfig			
	for i in "$@"; do 					
		echo $i >> ./con.myconfig
	done
	IFS=$IFS_OLD
}

# Если файл конфигурации существует, запоминаем конфигурацию, иначе создаем новый файл 
if [[ -f "./con.myconfig" ]]; then 	
	i=0					
	while read line; do  	
	    config_now[$i]="$line"
	    i=$(($i+1))
	done < ./con.myconfig
	
else						 
	config_rec "${config[@]}"        	
fi

# Просмотр и изменение временых файлов
function view_edit_temporary { 
echo "Введите [1-2] для выбора
1. Посмотреть список временных файлов
2. Задать заново" 	
		read choice		
		if [ $choice -eq 1 ]; then	
			echo " "		
			echo ${config_now[0]}
		elif [ $choice -eq 2 ]; then
			config_now[0]=""
			echo -n "Введите расширения через пробел: " 	
			read -a arr_extension 						# Ввод массива состоящий из расширений
			config_now[0]=${arr_extension[@]}			# Изменяем текущую конфигурацию для расшишений
			config_rec "${config_now[@]}" 				# Перезаписываем конфигурацию в con.myconfig
		else
			echo "Вы ввели не верный номер "
		fi
	return
}

# Просмотр и изменение рабочих файлов
function view_edit_work {
echo "Введите [1-2] для выбора 
1. Просмотреть список рабочих файлов
2. Задать заново список рабочих файлов"
echo " "
		read choice							
		if [ $choice -eq 1 ]; then	
			echo " "		
			echo ${config_now[1]}
		elif [ $choice -eq 2 ]; then
			config_now[1]=""
			echo "Введите расширения через пробел: " 	
			read -a arr_work 						# Ввод массива состоящий из расширений
			config_now[1]=${arr_work[@]}	
			config_rec "${config_now[@]}" 		
		else
			echo "Вы ввели не верный номер "
		fi
	return
}

# Просмотр и изменение рабочей папки
function view_edit_workdir {
echo "Введите [1-2] для выбора
1. Посмотреть рабочую папку скрипта
2. Задать заново рабочую папку скрипта "
echo " "
		read choice							
		if [ $choice -eq 1 ]; then	
			echo " "
			echo ${config_now[2]}			
		elif [ $choice -eq 2 ]; then
			echo "Введите новый путь к рабочей папке: "
			read path_new 					# Считываем строку - путь к рабочей папке
			config_now[2]=$path_new			
			config_rec "${config_now[@]}"
		else
			echo "Вы ввели не верный номер "
		fi
	return
}

# Просмотр и изменение программы
function view_edit_programm {
echo "Введите [1-2] для выбора
1. Выполнить команду
2. Изменить  команду"
echo " "
		read choice							
		if [ $choice -eq 1 ]; then
			eval "${config_now[3]}"			# Выполняем команду
		elif [ $choice -eq 2 ]; then	
			echo "Введите новую команду: "
			read  command_new				# Считываем команду - строка
			config_now[3]=$command_new
			config_rec "${config_now[@]}"	
		else
			echo "Вы ввели не верный номер "
		fi
	return
}

# Просмотр всех строк, ограниченных апострофами, во всех рабочих файлах
function apostrophe() {
	for i in "${config_now[1]}"; do
			grep "^'[[:print:]]*'$" ${config_now[2]}$i # При помощи регулярного выражения выводим нужные строки  
		done
	return
}

# Просмотр объёма каждого мусорного файла
function trash {
	for i in "${config_now[0]}"; do
			du -h ${config_now[2]}$i  # При помощи команды du выводим объем мусорных файлов
		done
	return
}

# Удаление определенного расширения из списка временных файлов
del_temp() { 										   
			str_extension_new=""		# Строка,  которая хранит все расширения кроме удаляемой			
			for i in ${config_now[0]}; do 			
				if [[ "$i" != "$str_extension" ]]; then		
					str_extension_new+=" "$i 	# Добовляем все расширения кроме удаляемой
				fi
			done
			config_now[0]=$str_extension_new		
			config_rec "${config_now[@]}"		
	return
}

# Удаление определенного расширения из списка рабочих файлов
del_work() {
			str_work_new=""			  		
			for i in ${config_now[1]}; do 			
				if [[ "$i" != "$str_work" ]]; then		
					str_work_new+=" "$i 	
				fi
			done
			config_now[1]=$str_work_new	
			config_rec "${config_now[@]}"			
		
	return
}


# Тихий режим 
if ! [ $# -eq 0 ]; then
	if [ "$1" == "-s" ]; then
		if [ "$2" == "-v_temp" ]; then 		# Просмотр временых файлов
			echo "${config_now[0]}"
		elif [ "$2" == "-e_temp" ]; then 	# Изменение временых файлов
			config_now[0]=""				
			count=0
			for i in "$@"; do
				if [[ $count > 1 ]]; then 	# Записываем расширения в 1 эл массива
					config_now[0]+=" ""$i"
					config_rec "${config_now[@]}" # Обновляем конфиг
				fi
				count=$((count+1))
			done

		elif [ "$2" == "-a_temp" ]; then 	# Добавление  конкретного расширения из списка временных файлов	
			config_now[0]+=" ""$3" 			# Изменяем текущую конфигурацию для расшишений
			config_rec "${config_now[@]}"
		elif [ "$2" == "-d_temp" ]; then  	#  Удаление конкретного расширения из списка временных файлов
			str_extension="$3"
			del_temp "$str_extension"

		elif [ "$2" == "-v_work" ]; then 	# Просмотр рабочих файлов
			echo ${config_now[1]}
		elif [ "$2" == "-e_work" ]; then 	# Изменение рабочих файлов
			config_now[1]=""	
			count=0
			for i in "$@"; do
				if [[ $count > 1 ]]; then
					config_now[1]+=" ""$i"
					config_rec "${config_now[@]}" 
				fi
				count=$((count+1))
			done

		elif [ "$2" == "-a_work" ]; then 	# Добавление  конкретного расширения из списка рабочих файлов
			config_now[1]+=" ""$3" 		
			config_rec "${config_now[@]}"	
		elif [ "$2" == "-d_work" ]; then 	#  Удаление конкретного расширения из списка временных файлов
			str_work="$3"
			del_work "$str_work"

		elif [ "$2" == "-v_workdir" ]; then 	#  Просмотр рабочей папки скрипта
			echo ${config_now[2]}
		elif [ "$2" == "-e_workdir" ]; then 	#  Изменение рабочей папки скрипта
			config_now[2]="$3"		
			config_rec "${config_now[@]}"

		elif [ "$2" == "-del_all_temp" ]; then 	#  Удаление всех временных файлы
			for i in ${config_now[0]}; do
			rm -f ${config_now[2]}/${i}		
			done

		elif [ "$2" == "-prog" ]; then 	# Выполнение изаписанной команды.	
			${config_now[3]}
		elif [ "$2" == "-e_prog" ]; then 	# Изменяем записанную команду
			config_now[3]="$3"		
			config_rec "${config_now[@]}"

		elif [ "$2" == "-apostrophe" ]; then # Просмотр всех строки, ограниченные апострофами
			apostrophe
		elif [ "$2" == "-trash" ]; then 	# Просмотр объёма каждого мусорного файла.
			trash
		fi
	fi
exit
fi 

# Меню
while : 
do
echo " "
echo "Введите [0-9] для выбора меню
1. Просмотреть или задать заново список временных файлов.
2. Добавить или удалить конкретное расширение из списка временных файлов.
3. Просмотреть или задать заново список рабочих файлов.
4. Добавить или удалить конкретное расширение из списка рабочих файлов.
5. Просмотреть, изменить или задать заново рабочую папку скрипта.
6. Удалить временные файлы.
7. Выполнить или изменить записанную команду.
8. Просмотреть все строки, ограниченные апострофами, во всех рабочих файлах
9. Просмотреть объём каждого мусорного файла.
0. Выйти
	"
	read menu 									
	if [ $menu -eq 0 ]; then	# Выход из программы
		echo "Bye-bye"
		exit  							
	fi
	# 1. Просмотреть или задать заново список временных файлов.
	if [ $menu -eq 1 ]; then				
		view_edit_temporary
	# 2. Добавить или удалить конкретное расширение из списка временных файлов
	elif [ $menu -eq 2 ]; then
echo "Введите [1-2] для выбора 
1. Добавить конкретное расширение 
2. Удалить конкретное расширение "
echo " "
		read choice							
		if [ $choice -eq 1 ]; then
			echo "Текущий список временных расширени: ${config_now[0]}"
			echo -n "Введите расширение: " 	
			read str_extension 			# Ввод строки расширения
			config_now[0]+=" "$str_extension 		
			config_rec "${config_now[@]}" 			
		elif [ $choice -eq 2 ]; then
			echo "Текущий список временных расширени: ${config_now[0]}"
			echo -n "Введите расширение: " 
			read str_extension			
			del_temp "$str_extension"
			config_now[0]=$str_extension_new		
			config_rec "${config_now[@]}"
		else
			echo "Вы ввели не верный номер "
		
		fi
	# 3. Просмотреть или задать заново список рабочих файлов.
	elif [ $menu -eq 3 ]; then
		view_edit_work

	# 4. Добавить или удалить конкретное расширение из списка рабочих файлов.		
	elif [ $menu -eq 4 ]; then
echo "Введите [1-2] для выбора 
1. Добавить конкретное расширение 
2. Удалить конкретное расширение "
echo " "
		read choice							
		if [ $choice -eq 1 ]; then
			echo "Текущий список рабочих расширени: ${config_now[1]}"
			echo -n "Введите расширение: " 	
			read str_work	 						
			config_now[1]+=" "$str_work     		
			config_rec "${config_now[@]}" 			
		elif [ $choice -eq 2 ]; then
			echo "Текущий список рабочих расширени: ${config_now[1]}"
			echo -n "Введите расширение: " 
			read str_work  
			del_work "$str_work"
		else
			echo "Вы ввели не верный номер "
		fi

	# 5. Просмотреть, изменить или задать заново рабочую папку скрипта.
	elif [ $menu -eq 5 ]; then
		view_edit_workdir

	# 6.  Удалить временные файлы.
	elif [ $menu -eq 6 ]; then
		for i in ${config_now[0]}; do
			rm -f ${config_now[2]}/${i}		# f Удаление без вопросов 	
		done

	# 7. Выполнить или изменить записанную команду.
	elif [ $menu -eq 7 ]; then
		view_edit_programm
	# 8. Просмотреть все строки, ограниченные апострофами, во всех рабочих файлах
	elif [ $menu -eq 8 ]; then
		apostrophe
	# 9. Просмотреть объём каждого мусорного файла.
	elif [ $menu -eq 9 ]; then
		trash
	else
		echo "
			Вы ввели неверное значения, для выбора меню
			Введите заново"
	fi
done
