# -- 2 ways of Creating function --


function function-name() {
	#code goes here
}

function-name() {
	#code goes here
}


# -- Calling a function --

function hello() {
	echo "Hello"
}
hello


# -- Functions can call other function --

function hello() {
	echo "Hello Mers!"
	now
}

function now() {
	echo "It's $(date +%r)"
}
hello