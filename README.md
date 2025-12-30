# Bash Shell Script Database Management System (DBMS)

## The Project aims to develop DBMS that will enable users to store and retrieve the data from Hard-disk.



```
# Team Nine Telecom Application Development
  _______  _______  _______  __   __    __    _  ___   __    _  _______ 
 |       ||       ||       ||  |_|  |  |  |  | ||   | |  |  | ||       |
 |_     _||    ___||   _   ||       |  |   |_| ||   | |   |_| ||    ___|
   |   |  |   |___ |  |_|  ||       |  |       ||   | |       ||   |___ 
   |   |  |    ___||       ||       |  |  _    ||   | |  _    ||    ___|
   |   |  |   |___ |   _   || ||_|| |  | | |   ||   | | | |   ||   |___ 
   |___|  |_______||__| |__||_|   |_|  |_|  |__||___| |_|  |__||_______|

 Bash Shell Script Database Management System (DBMS)

 ###########################################################################
 
      ################ By Mohammed Ali & Ziad Khattab ################
 
 ###########################################################################
 ```
  ### The Project Features:
    The Application will be CLI Menu based app, that will provide to user
    this Menu items:
      Main Menu:
      - Create Database
      - List Databases
      - Connect To Databases
      - Drop Database
      Upon user Connect to Specific Database, there will be new Screen with this Menu:
      - Create Table
      - List Tables
      - Drop Table
      - Insert into Table
      - Select From Table
      - Delete From Table
      - Update Table
    Bonus:
      - App accepts SQL Code or Uses GUI instead of the above menu
      based

### Prerequisites & Installation
To use the GUI version of this project, **Zenity** must be installed on your system.

#**For Ubuntu / Debian:**
```bash
sudo apt update
sudo apt install zenity

#For CentOS / RHEL / Fedora:
sudo dnf install zenity
# OR for older versions
sudo yum install zenity

The Project Features:

The Application provides two modes of operation: a standard CLI Menu and a Graphical User Interface (GUI).
1. CLI Mode (Terminal Based)

The Main Menu provides:

    Create Database

    List Databases

    Connect To Databases

    Drop Database

Table Operations (upon connection):

    Create Table

    List Tables

    Drop Table

    Insert into Table

    Select From Table (with filtering options)

    Delete From Table

    Update Table

2. GUI Mode (Zenity Based) [Bonus Implemented]

Located in the GUI_version/ folder, this mode replaces text menus with graphical dialogs:

    Interactive Menus: Select options using point-and-click lists.

    Forms: Input data using graphical entry fields and combo boxes.

    Visual Feedback: Success/Error popup messages instead of text output.

    File Browser: Visual selection for lists and database navigation.

    Smart Selection: * Select All

        Select Specific Column

        Select Multiple Columns

        Select with Condition (Where Clause)
