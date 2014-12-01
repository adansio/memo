#! /usr/bin/expect

set host [lindex $argv 0]

spawn ssh admin@$host
expect {
	"(yes/no)" {
		send "yes\r"

		exp_continue
	}

	"Password:" {
		send "0verhead.*\r"

		expect "#"
		send "reload all\r"

		expect "(y/n):"
		send "y\r"
		
		expect eof
	}
}
