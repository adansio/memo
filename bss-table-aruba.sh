#! /usr/bin/expect

set fid [open bss-table w+]

for {set i value1} {$i <= value2} {incr i 1} {
	
	spawn ssh admin@red.$i
	expect {
		"(yes/no)" {
			send "yes\r"

			exp_continue
		}
		"password:" {
			send "---pass--\r"
			expect  "#"
			
			send "sh ap bss-table \r"		
			expect "#"
	
			set capturedinfo $expect_out(buffer)
			puts $fid $capturedinfo	

			send "exit\r"

		}
	expect eof
	close $fid
	}
}


