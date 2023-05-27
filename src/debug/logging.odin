package debug


//= Imports
import "core:bytes"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:time"


//= Globals
been_used : bool = false


//= Procedures
create_log :: proc( name : string ) {
	//* If log already exists, delete it
	if os.exists(name) do os.remove(name)

	now            := time.now()
	hour, min, sec := time.clock_from_time(time.now())
	bytBuffer      :  bytes.Buffer
	strBuffer      :  strings.Builder

	//* Generate string and convert to byte array
	fmt.sbprintf(
		&strBuffer,
		"Creation Date: %2i/%2i/%2i | %2v:%2v:%2v | UTC",
		time.year(now), time.month(now), time.day(now),
		hour, min, sec,
	)
	bytes.buffer_write_string(&bytBuffer, strings.to_string(strBuffer))

	//* Save byte array to file
	os.write_entire_file(name, bytes.buffer_to_bytes(&bytBuffer))

	//* Clean up buffer
	bytes.buffer_destroy(&bytBuffer)
}

check_log :: proc() -> string {
	//* Create formated string
	builder : strings.Builder
	now		:= time.now()
	year	:= time.year(now)
	month	:= time.month(now)
	day		:= time.day(now)
	fmt.sbprintf(&builder, "%2i_%2i_%2i.txt", year, month, day)
	timecode := strings.to_string(builder)

	//* Check for log
	data, result := os.read_entire_file(timecode)
	if !result do create_log(timecode)

	return timecode
}

//TODO Fix?
logf :: proc( format : string, args: ..any ) {
	filename := check_log()
	data, _ := os.read_entire_file(filename)

	//* Initialize buffer
	buffer : bytes.Buffer
	bytes.buffer_init(&buffer, data)
	bytes.buffer_write_byte(&buffer, '\n')

	//* Create formated string
	builder : strings.Builder
	fmt.sbprintf(&builder, format, args)
	formattedString := strings.clone(strings.to_string(builder))
	strings.builder_reset(&builder)

	//* Get current time
	hour, min, sec := time.clock_from_time(time.now())
	fmt.sbprintf(&builder, "[%2v:%2v:%2v]", hour, min, sec)
	timecode := strings.clone(strings.to_string(builder))
	strings.builder_reset(&builder)

	//* Concatenate strings
	bytes.buffer_write_string(&buffer, timecode)
	bytes.buffer_write_string(&buffer, formattedString)

	//* Append to file
	os.write_entire_file(filename, bytes.buffer_to_bytes(&buffer))
}
log :: proc( format : string ) {
	filename := check_log()
	data, _ := os.read_entire_file(filename)

	//* Initialize buffer
	buffer : bytes.Buffer
	bytes.buffer_init(&buffer, data)
	bytes.buffer_write_byte(&buffer, '\n')

	//* Create formated string
	builder : strings.Builder
	hour, min, sec := time.clock_from_time(time.now())
	fmt.sbprintf(&builder, "[%2v:%2v:%2v]", hour, min, sec)
	timecode := strings.to_string(builder)
	strings.builder_reset(&builder)

	//* Concatenate strings
	bytes.buffer_write_string(&buffer, timecode)
	bytes.buffer_write_string(&buffer, format)

	//* Append to file
	os.write_entire_file(filename, bytes.buffer_to_bytes(&buffer))
}