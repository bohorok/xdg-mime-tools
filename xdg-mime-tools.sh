#! /usr/bin/env bash

########################## MIT License ############################

# Copyright (c) 2023 bohorok
#  https://github.com/bohorok

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

######################## DEPENDENCIES #############################
# xdg-utils : v1.1.3+45+g301a1a4-1
# findutils : v4.9.0-3
# glib : v2 2.76.4-1
# gawk : v5.2.2-1
# desktop-file-utils : v0.26-2
# shared-mime-info : v2.2+13+ga2ffb28-1

##################### SECTION CONFIG SCRIPT ##########################
# select directories in serching mime type files
file_types_in_directories="$HOME/Dokumenty/ $HOME/Pobrane/ $HOME/Obrazy/ $HOME/Muzyka/ $HOME/Wideo/ $HOME/Grafika/" ;
searched_desktop_localizations="/usr/share/applications/ /usr/local/share/applications/ $HOME/.local/share/applications/ /opt/";
favorite_editor="subl"
find_xml_file="$HOME"
# COLORS
head_colors="\033[1;100;93m"
text_color="\033[93m"
end_colors="\033[0m"
##################### END SECTION CONFIG SCRIPT #######################

function select_function()
{
	clear
	echo ""
	echo -e "${head_colors}~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MAIN MENU ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${end_colors}"
	 echo -e "\t 1. File info"
	 echo -e "\t 2. Refresh mimeinfo.cache - database cache for desktop file"
	 echo -e "\t 3. Refresh mime directories: */mime"  
	 echo -e "\t 4. Set default appplication for mime type"
	 echo -e "\t 5. Edit mimeapps.list for all users - Additional associations / blocked associations"
	 echo -e "\t 6. Edit mimeapps.list for current user - Additional associations / blocked associations"
	 echo -e "\t 7. Create new mime-type, for advanced users"
	 echo -e "\t 8. Install new mime-type for all users"
	 echo -e "\t 9. Install new mime-type for current user"
	 echo -e "\t 10. Uninstall mime-type"
	 echo -e "\t q. Exit"
	 echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo ""
	read -p "select function : " selected_function 
case $selected_function  in
	"1")  file_info ;;
	"2") refresh_mime_database ;;
	"3") refresh_mime_database ;;
	"4") set_default_applications ;;
	"5") edit_mime_all_users ;;
	"6") edit_mime_current_user ;;
	"7") create_mime_type ;;
	"8") install_mime_all ;;
	"9") install_mime_user ;;
	"10") uninstall_mime_type ;;
	"q") exit ;;
esac
select_function ;
}

function create_mime_type()
{
	echo "" ;
	echo -e "${head_colors}~~~~~~~~~~~~~~~~~~~~ MAIN MENU / CREATE MIME TYPE ~~~~~~~~~~~~~~~~~~~~~~${end_colors}" ;
	echo "" ;
	echo -e "\tEnter name xml file, without extension, example: new-xmlfile : " ;
	read -p "$(echo -e '\tb-back \tq-quit \tName of xml file : ')" name_application ;
	case "$name_application" in
		"q") exit ;;
		"b") select_function ;;
		  * ) mime-xml-file > /tmp/${name_application}.xml ;
			    command_status ;
			    echo -e "\tYour mime type is in: /tmp/${name_application}.xml" ;
			    echo -e "\tPress any key to edit this file" ;
			    read -rn1 -p "$(echo -e '\t')" ;
			    $favorite_editor -n /tmp/${name_application}.xml ;;
	esac
}

function uninstall_mime_type()
{
	echo "" ;
	echo -e "${head_colors}~~~~~~~~~~~~~~~~~~ MAIN MENU / UNINSTALL MIME TYPE ~~~~~~~~~~~~~~~~~~~~~${end_colors}" ;
	local system_mime_files="/usr/share/mime/packages/" ;
	local current_user_mime_files="$HOME/.local/share/mime/packages/" ;
	echo "" ;
	echo -e "                  ${text_color}MIME FILES FOR SYSTEM, ALL USERS${end_colors}" ;
	if [[ -d "$system_mime_files" ]]; then
		ls "$system_mime_files"*.xml 2>/dev/null ;
		if [[ $? != 0 ]]; then
			echo "" ;
			echo -e "\tDirectory ${system_mime_files} exist but is empty, haven't installed mime-files.xml" ;
		fi
	else
		echo "" ;
		echo -e "\t${system_mime_files} do not exist, you install xdg-utils packet" ;
		echo -e "\tPress any key to back MAIN MENU" ;
		read -rn1 -p "$(echo -e '\t')";
		select_function ;
	fi
	echo "" ;
	echo -e "                  ${text_color}MIME FILES FOR CURRENT USER${end_colors}" ;
	if [[ -d "$current_user_mime_files" ]]; then
		ls "$current_user_mime_files"*.xml 2>/dev/null ;
		if [[ $? != 0 ]]; then
			echo "" ;
			echo -e "\tDirectory ${current_user_mime_files} exist but is empty," ;
			echo -e "\thaven't installed mime-files.xml. Select install mime file xml for user" ;
			echo -e "\tthen create mime-files.xml" ;
		fi
		else
			echo "" ;
			echo -e "\t${current_user_mime_files} do not exist, select install mime file xml for user" ;
			echo -e "\tthen create mime directory and mime-files.xml" ;
	fi
	local mime_to_uninstall
	echo ""
	echo -e "\tSelect mime file to uninstall : "
	read -p "$(echo -e '\tb-back \tq-quit \t/full path/name.xml : ')" mime_to_uninstall ;
	case "$mime_to_uninstall" in
		"b") select_function ;;
		"q") exit ;;
			*) if [[ $mime_to_uninstall = $system_mime_files*.xml ]]; then
				sudo xdg-mime uninstall --mode system $mime_to_uninstall ;
				command_status ;
			elif [[ $mime_to_uninstall = $current_user_mime_files*.xml ]]; then
				xdg-mime uninstall --mode user $mime_to_uninstall ;
				command_status ;
			fi;;
	esac
	echo -e "\tUninstall complete, press any key to  back to MAIN MENU" ;
	read -rn1 -p "$(echo -e '\t')";
	select_function ;
}

function install_mime_user()
{
	echo "" ;
	echo -e "${head_colors}~~~~~~~~~~~~~~~ MAIN MENU / INSTALL XML MIME FILE FOR USER ~~~~~~~~~~~~~~~${end_colors}" ;
	find-mime-xml ;
	local install_stop_decision
	echo ""
	echo -e "\tDo you want install ${name_mimetypes_file} in $HOME/.local/share/mime/packages/ ?" ;
	read -p "$(echo -e '\tb-back \tq-quit \tc-continue :  ')" install_stop_decision ;
			case "$install_stop_decision" in
				"c") xdg-mime install --mode user $mimetypes_file ;
						command_status ;
						if [[ -e "$HOME/.local/share/mime/packages/$name_mimetypes_file" ]]; then
							echo -e "\tThe file ${mimetypes_file} was installed in $HOME/.local/share/mime/packages/" ;
						else
							echo -e "\tThe file ${mimetypes_file} was't installed in $HOME/.local/share/mime/packages/" ;
						fi ;
						echo "" ;
						echo -e "\tPress any key to continue" ;
						read -rn1 -p "$(echo -e '\t')" ;;
				"b") select_function ;;
				"q") exit ;;
			esac
}

function install_mime_all()
{
	echo "" ;
	echo -e "${head_colors}~~~~~~~~~~~~~~~ MAIN MENU / INSTALL XML MIME FILE FOR ALL ~~~~~~~~~~~~~~~~${end_colors}" ;
	find-mime-xml ;
	local install_stop_decision
	echo ""
	echo -e "\tDo you want install ${name_mimetypes_file} in /usr/share/mime/packages/ ?" ;
	read -p "$(echo -e '\tb-back \tq-quit \t c-continue  : ')" install_stop_decision ;
			case "$install_stop_decision" in
				"c") sudo xdg-mime install --mode system "$mimetypes_file" ;
						command_status ;
						if [[ -e "/usr/share/mime/packages/$name_mimetypes_file" ]]; then
							echo -e "\tThe file ${mimetypes_file} was installed in /usr/share/mime/packages/" ;
						else
							echo -e "\tThe file ${mimetypes_file} was't installed in /usr/share/mime/packages/" ;
						fi ;
						echo "" ;
						echo -e "\tPress any key to continue" ;
						read -rn1 -p "$(echo -e '\t')" ;;
				"b") select_function ;;
				"q") exit ;;
			esac
}

function find-mime-xml()
{
	echo  -e "\tfound list xml files in ${find_xml_file} and /tmp directories" ;
	echo  -e "\t(Configure this directories in config section script)" ;
	echo "" ;
	find /tmp -maxdepth 1 -type f -iname '*.xml' ;
	find "$find_xml_file" -maxdepth 3 -type f -iname '*.xml' ;
	echo "" ;
	echo -e "\tSelect xml file containing mime informations : " ;
	read -p "$(echo -e '\tb-back \tq-quit \t /full-path/mime-file.xml : ')" mimetypes_file ;
	case $mimetypes_file in
		"b") select_function ;;
		"q") exit ;;
		  * ) if [[ ! -e "$mimetypes_file" ]]; then
						echo -e "\tFile not exist, you enter another name of file" ;
						find-mime-xml ;
					else
						name_mimetypes_file=$(echo "$mimetypes_file" | awk -F "/" '{ print $NF }') ;
					  fi ;;
	esac
}

function edit_mime_all_users()
{
	 if [[ -f /etc/xdg/$XDG_CURRENT_DESKTOP-mimeapps.list ]]; then
			sudo $favorite_editor -n /etc/xdg/$XDG_CURRENT_DESKTOP-mimeapps.list
		elif [[ -f /etc/xdg/mimeapps.list ]]; then
			sudo $favorite_editor -n /etc/xdg/mimeapps.list
		elif [[ -f /usr/local/share/applications/mimeapps.list ]]; then
			$favorite_editor -n /usr/local/share/applications/mimeapps.list
		else
			echo ""
			echo -e " \tYou don't have mimeapps.list file for all users, do you want create file in /etc/xdg/ ?"
			echo ""
			read -p "$(echo -e '\tb-back \tq-quit \ty-yes \tn-no : ')" create_file_all
			case $create_file_all in
				"b") select_function ;;
				"q") exit ;;
				"y") sudo echo -e "[Default Applications]\n\n[Added Associations]\n\n[Removed Associations]\n\n" > /tmp/mimeapps.list ;
					  echo ""
					sudo mv -i -v /tmp/mimeapps.list /etc/xdg/ ;
					command_status ;
					echo -e "\tPress any key to edit this file" ;
					read -rn1 -p "$(echo -e '\t')";
					sudo $favorite_editor -n /etc/xdg/mimeapps.list ;;
				"n") select_function ;;
			esac
	fi
}

function edit_mime_current_user()
{
	if [[ -f $HOME/.config/mimeapps.list ]]; then
			$favorite_editor -n $HOME/.config/mimeapps.list
		elif [[ -f $HOME/.local/share/applications/mimeapps.list ]]; then
			$favorite_editor -n $HOME/.local/share/applications/mimeapps.list
		else
			echo ""
			echo -e "\tYou don't have mimeapps.list file for current user, \n\tdo you want create file in $HOME/.config/mimeapps.list ?"
			echo ""
			read -p "$(echo -e '\tb-back \tq-quit \ty-yes \tn-no : ')" create_file_user
			case $create_file_user in
				"b") select_function ;;
				"q") exit ;;
				"y") echo -e "[Default Applications]\n\n[Added Associations]\n\n[Removed Associations]\n\n" > /tmp/mimeapps.list ;
					  echo "" ;
					  mv -n -v /tmp/mimeapps.list $HOME/.config/ ;
					command_status ;
					echo -e "\tPress any key to edit file" ;
					read -rn1 -p "$(echo -e '\t')" ;
					$favorite_editor -n $HOME/.config/mimeapps.list ;;
				"n") select_function ;;
			esac
			fi
}

function file_info()
{
	echo "" ;
	echo -e "${head_colors}~~~~~~~~~~~~~~~~~~~~~ MAIN MENU / FILE MIME INFO ~~~~~~~~~~~~~~~~~~~~~~~${end_colors}" ;
	echo "" ;
	echo -e "            ${text_color}LISTS FILES FROM SELECTED DIRECTORIES${end_colors}" ;
	echo "       (configure this directories in config section script)" ;
	echo "" ;
	# find $file_types_in_directories -maxdepth 3 -type f -iname '*.*' ;
	ls --indicator-style=file-type  --quoting-style=literal $file_types_in_directories ;
	echo "" ;
	echo -e "                             ${text_color}SELECT MODE${end_colors}" ;
	echo ""
	echo -e "\t1. Select name of file from above" ;
	echo -e "\t2. Enter full path manually: /path/filename.ext" ;
	echo ""
	read -p "$(echo -e '\tq-quit \tm-main menu \tb-defautl applications \t1/2 option : ')" insert_mode ;
	echo "" ;
	case $insert_mode in
		"1") read -p "$(echo -e '\tselect name of file and press enter : ')" selected_file ; 
			echo "";
			auto_full_path_to_files=$(find ${file_types_in_directories} -maxdepth 1  -type f -iname "${selected_file}"); 
			mime_type=$(xdg-mime query filetype "${auto_full_path_to_files}") ;
			default_application=$(xdg-mime query default ${mime_type}) ;
			command_status ;
			echo -e "${text_color}. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .${end_colors}";
			echo -e "\t \t  ${text_color}>> xdg-mime query information <<${end_colors}";
			echo -e "\t mime type is, ${mime_type}" | awk -F "," '{ printf "%-48s %-4s %s\n", $1,">>>>", $2}';
			echo -e "\t default application for open ${mime_type}, ${default_application}" | awk -F "," '{ printf "%-48s %-4s %s\n", $1,">>>>", $2}';
			echo -e "";
			echo -e "\t \t  ${text_color}>> gio mime information <<${end_colors}";
			echo -e "\t `gio mime ${mime_type}`"
			echo -e "${text_color}. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .${end_colors}";
			echo "";;
		"2") read -p "$(echo -e '\tInsert full path to file  and press enter: /path/namefile : ')" manual_full_path_to_files ;
			echo "";
			 mime_type_manual=$(xdg-mime query filetype "${manual_full_path_to_files}") ;
			 default_application=$(xdg-mime query default ${mime_type_manual}) ;
			 command_status ;
			echo -e "${text_color}. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .${end_colors}";
			echo -e "\t mime type is, ${mime_type_manual}" | awk -F "," '{ printf "%-48s %-4s %s\n", $1,">>>>", $2}';
			echo -e "\t default application for open ${mime_type_manual}, ${default_application}" | awk -F "," '{ printf "%-48s %-4s %s\n", $1,">>>>", $2}';
			echo -e "${text_color}. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .${end_colors}";
			echo "";;
		"m") select_function ;;
		"b") set_default_applications ;;
		"q") exit ;;
	esac
			echo -e "\tPress any key to continue FILE MIME INFO"
			read -rn1  -p "$(echo -e '\t')"
			file_info
}

function refresh_mime_database()
{
	echo "" ;
	echo -e "${head_colors}~~~~~~~~~~~~~~~~~ MAIN MENU / REFRESH MIME DATABASE ~~~~~~~~~~~~~~~~~~~~${end_colors}"
	echo -e "\t 1. Refresh mimeinfo.cache in default desktop file localisations:"
	echo -e "\t    /usr/share/applications/mimeinfo.cache"
	echo -e "\t    /usr/local/share/applications/mimeinfo.cache"
	echo -e "\t 2. Refresh mimeinfo.cache in desktop directoy for current user "
	echo -e "\t    $HOME/.local/share/applications/mimeinfo.cache"
	echo -e "\t 3. Refresh mimeinfo.cache - Insert path to desktop files directories manually"
	echo -e "\t 4. Refresh mime directories */mime"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	read -p "$(echo -e '\tb-back \tq-quit \t1/2/3/4 option : ')" input_mode
	case $input_mode in
		"b")	select_function ;;
		"q")	exit ;;
		"1")	echo "" ;
				sudo update-desktop-database -v ;
				command_status ;;
		"2") echo "" ;
				update-desktop-database -v $HOME/.local/share/applications/;
				command_status ;;
		"3")	echo "" ;
				read -p "$(echo -e '\tselect path manually : ')" desktop_directories ;
				sudo update-desktop-database $desktop_directories ; 
				command_status ;;
		"4")	refresh_mime_directories ;;
	esac
	echo "" ;
	echo -e "\tPress any key to continue REFRESH MIME DATABASE "
	read -rn1 -p "$(echo -e '\t')"
	refresh_mime_database
}

function refresh_mime_directories()
{
	echo "" ;
if [[ -d $HOME/.local/share/mime/ ]]; then
	update-mime-database -V $HOME/.local/share/mime/ ;
			if [[ -d /usr/local/share/mime/ ]]; then
				update-mime-database -V /usr/local/share/mime/ ;
			fi
fi
	echo "" ;
	sudo update-mime-database -V /usr/share/mime/ ;
	refresh_mime_database ;
}

function set_default_applications()
{
	if [[ -e $HOME/.config/back-mimeapps.list ]]; then
				mv $HOME/.config/back-mimeapps.list $HOME/.config/mimeapps.list ;
	fi
	echo "" ;
	echo -e "${head_colors}~~~~~~~~~~~~~~~~~ MAIN MENU / SET DEFAULT APPLICATIONS ~~~~~~~~~~~~~~~~~${end_colors}"
	echo -e "\t 1. Specify file mime type for file"
	echo -e "\t 2. Show installed application  >>>  related file.desktop"
	echo -e "\t 3. Set default application for mime type - current user"
	echo -e "\t 4. Set default application for mime type - all user"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	read -p "$(echo -e '\tb-back \tq-quit 1/2/3/4 option : ')" option_set_default_applications ;
	case $option_set_default_applications in 
		"b") select_function ;;
		"q") exit ;;
		"1") file_info ;;
		"2") show_installed_applications ;;
		"3") echo "" ; 
					if [[ ! -e $HOME/.config/mimeapps.list ]]; then
						echo -e "[Default Applications]\n\n[Added Associations]\n\n[Removed Associations]\n\n" > $HOME/.config/mimeapps.list ;
				 fi 
					show_installed_applications ;
					read -p "$(echo -e '\tEnter default aplication (name desktop file) for user : ')" application_user;
				   	read -p "$(echo -e '\tEnter mime type : ')" mimetype_user;
					xdg-mime default $application_user $mimetype_user ;
					command_status ;;
		"4") echo "" ; 
				if [[ -e $HOME/.config/mimeapps.list ]]; then
					echo -e "\tExist file mimeapps.list for current user, this file takes precedence over the" ;
					echo -e "\tsettings for everyone, do you want to continue changing for everyone ? : " ;
					echo "" ;
					echo -e "\tIf you choose yes, name your file mimeapps.list will be changed for a while" ;
					echo -e "\tYou don't interrupt script execution width keyboard shortcuts (ctrl +c, etc.)," ;
					echo -e "\tafter ending function of script the file name will be restored" ;
					echo ""
					read -p "$(echo -e '\tb-back \tq-quit \ty-yes \tn-no : ')" default_all_or_user ;
					echo "" ;
					case "$default_all_or_user" in
						"y") mv $HOME/.config/mimeapps.list $HOME/.config/back-mimeapps.list
									set_default_applications_all ;;
						"n") set_default_applications ;;
						"b") select_function ;;
						"q") exit ;;
					esac
				else
				set_default_applications_all ;
				fi
esac
	set_default_applications ;
}

function show_installed_applications()
{
				list_desktop_files=$(find $searched_desktop_localizations -type f -iname '*.desktop');
			  setting_patch_to_file=;
			for item_desktop_files in $list_desktop_files
				do
			  	name_desktop_file=$(echo ${item_desktop_files} | awk -F "/" '{ print $NF }');
		 		name_application=$(cat ${item_desktop_files} | awk -F "=" '$1 == "Name" { print $2 }');
				patch_to_file=$(echo ${item_desktop_files} | awk -F "/" 'OFS = "/" { $NF=""; print }');
				if [[ ${setting_patch_to_file} != ${patch_to_file} ]]
				then
					setting_patch_to_file=${patch_to_file};
					echo ""
					echo -e "${text_color}\t \t ${setting_patch_to_file}${end_colors}";
					echo -e "${text_color}Name applications \t \t \t Name desktop file${end_colors}"
					echo ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ."
					echo -e "${name_application}, ${name_desktop_file}" | awk -F "," '{ printf "%-35s %-4s %s\n", $1,">>>", $2}';
				elif [[ ${setting_patch_to_file} = ${patch_to_file} ]] 
					then
					echo -e "${name_application}, ${name_desktop_file}" | awk -F "," '{ printf "%-35s %-4s %s\n", $1,">>>", $2}';
				fi
				done
				echo "" ;
}

function set_default_applications_all()
{
	if [[ -e /etc/xdg/$XDG_CURRENT_DESKTOP-mimeapps.list ]]; then
				sudo	mv /etc/xdg/$XDG_CURRENT_DESKTOP-mimeapps.list $HOME/.config/mimeapps.list ;
				show_installed_applications ;
				read -p "$(echo -e '\tEnter default aplication for all user (name desktop file) : ')" application_all ;
			  	read -p "$(echo -e '\tEnter mime type : ')" mimetype_all ;
				xdg-mime default $application_all $mimetype_all ;
				command_status ;
				sudo	mv $HOME/.config/mimeapps.list /etc/xdg/$XDG_CURRENT_DESKTOP-mimeapps.list ;
				elif [[ -e /etc/xdg/mimeapps.list ]]; then
							sudo mv /etc/xdg/mimeapps.list $HOME/.config/ ;
							show_installed_applications ;
							read -p "$(echo -e '\tEnter default aplication for all user (name desktop file) : ')" application_all ;
					  		read -p "$(echo -e '\tEnter mime type : ')" mimetype_all ;
							xdg-mime default $application_all $mimetype_all ;
							command_status ;
							sudo mv $HOME/.config/mimeapps.list /etc/xdg/ ;
				elif [[ -e /usr/local/share/applications/mimeapps.list ]]; then
							sudo mv /usr/local/share/applications/mimeapps.list $HOME/.config/
							show_installed_applications ;
							read -p "$(echo -e '\tEnter default aplication for all user (name desktop file) : ')" application_all ;
					  		read -p "$(echo -e '\tEnter mime type : ')" mimetype_all ;
							xdg-mime default $application_all $mimetype_all ;
							command_status ;
							sudo mv $HOME/.config/mimeapps.list /usr/local/share/applications/ ;
						else
									echo -e "[Default Applications]\n\n[Added Associations]\n\n[Removed Associations]\n\n" > /tmp/mimeapps.list ;
					  				echo "" ;
									sudo mv -i -v /tmp/mimeapps.list /etc/xdg/ ;
									command_status ;
									echo -e "\tFile mimeapps.list for all users is created in /etc/xdg/" ;
									echo -e "\tPress any key to continue settings default application for mime" ;
									read -rn1 -p "$(echo -e '\t')";
									set_default_applications_all ;
	fi
	set_default_applications ;
}

function mime-xml-file()
{
	echo '<?xml version="1.0"? encoding="UTF-8"
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="your/mime-type">
    <comment>Your comment</comment>
    <comment xml:lang="your language">comment in your language</comment>
    <!--Matching mime type based on reading the file header, this section is optional-->
    <magic priority="50">
      <match type="string" offset="0" value="diff\t"/>
      <match type="string" offset="0" value="***\t"/>
      <match type="string" offset="0" value="Common subdirectories: "/>
    </magic>
    <!--Discard all match patterns, use only the pattern from this file -->
    <magic-deleteall/>
    <!--Matching mime type based on extensions of file -->
    <glob pattern="*.diff"/>
    <glob pattern="*.patch"/>
    <!--Discard all match patterns, use only the pattern from this file -->
    <glob-deleteall/>
    <!--Assignment name of icon for mime-type  -->
    <icon name="your icon name from icon directories - application/msword:x-office-document"/>
    <!--Assignment name of icon for category mime-type  -->
    <generic-icon name="your icon name from icon directories - application/msword:x-office-document"/>
  </mime-type>
</mime-info>
    <!--See full mime specs on the website:
     https://specifications.freedesktop.org/shared-mime-info-spec/shared-mime-info-spec-0.21.html  -->
     '
}

function command_status()
{
	if [[ $? = 0 ]]; then
		echo ""
		echo -e "\tsucces:"
	else
		echo ""
		echo -e "\tfault:"
	fi
}

select_function
