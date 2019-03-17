
// vim: set filetype=c ts=8 noexpandtab:

// simple, fast, memory-eating iter

//@summary Adds a value to an iterator.
//@param iter the iterator to add the value to
//@param value the value to add
//@remarks Is implemented as a preprocessor replacement.
//@remarks Caller does not need to check if the iter already contains the value.
//@remarks Use {@link iter_add_us} if {@param value} is not a constant or variable.
//@seealso iter_add_us
stock iter_add(iter, value) {
	this_function _ should_not _ be_called
}
//@summary Adds a dynamic value (not a constant or variabe) to an iterator.
//@param iter the iterator to add the value to
//@param value the value to add
//@remarks Is implemented as a preprocessor replacement.
//@remarks Caller does not need to check if the iter already contains the value.
//@seealso iter_add
stock iter_add_us(iter, value) {
	this_function _ should_not _ be_called
}
//@summary Removes a value from an iterator.
//@param iter the iterator to remove the value from
//@param value the value to remove
//@remarks Is implemented as a preprocessor replacement.
//@remarks Caller does not need to check if the iter contains the value.
//@remarks Use {@link iter_remove_us} if {@param value} is not a constant or variable.
//@seealso iter_remove_us
//@seealso iter_clear
stock iter_remove(iter, value) {
	this_function _ should_not _ be_called
}
//@summary Removes a dynamic value (not a constant or variable) from an iterator.
//@param iter the iterator to remove the value from
//@param value the value to remove
//@remarks Is implemented as a preprocessor replacement.
//@remarks Caller does not need to check if the iter contains the value.
//@seealso iter_remove
//@seealso iter_clear
stock iter_remove_us(iter, value) {
	this_function _ should_not _ be_called
}
//@summary Check if {@param iter} contains the value {@param value}
//@param iter the iterator to check for
//@param value the value to check for
//@remarks Is implemented as a preprocessor replacement.
//@remarks {@param value} should not be out of bounds!
//@returns {@code 0} if the the iterator does not contain {@param value}
stock iter_has(iter, value) {
	this_function _ should_not _ be_called
}
//@summary Removes all values from an iterator.
//@param iter the iterator to clear
//@remarks Is implemented as a preprocessor replacement.
stock iter_clear(iter) {
	this_function _ should_not _ be_called
}
//@summary Counts the amount of values this iterator has.
//@param iter the iterator to get the count of
//@remarks Is implemented as a preprocessor replacement.
//@returns The amount of values {@param iter} holds.
stock iter_count(iter) {
	this_function _ should_not _ be_called
}
//@summary Get a random value from an iterator.
//@param iter the iterator to get a random value of
//@remarks Is implemented as a preprocessor replacement.
//@remarks Check if {@link iter_count} is 0 first!
//@returns A random value from {@param iter} or {@code undefined} if the iterator is empty.
stock iter_random(iter) {
	this_function _ should_not _ be_called
}
//@summary Gets the value at the specified position in the iterator.
//@param iter the iterator to access
//@param position the position to access
//@remarks Is implemented as a preprocessor replacement.
//@remarks Usually used inside a foreach.
//@returns The value stored at {@param position} or {@code undefined} if this position is not used.
stock iter_access(iter, position) {
	this_function _ should_not _ be_called
}

#define Iter:%1[%2] %1[%2],%1@h[%2],%1@c=0;stock %1@t;const %1@m=%2

#define iter_add(%1,%2) if(!(%1@h[%2]))%1[%1@c++]=%2,%1@h[%2]=%1@c
#define iter_add_us(%1,%2) %1@t=%2;iter_add(%1,%1@t)
#define iter_remove(%1,%2); if(%1@h[%2]){if(%1@h[%2]!=%1@c--){%1[%1@h[%2]-1]=%1[%1@c];%1@h[%1[%1@c]]=%1@h[%2];}%1@h[%2]=0;}
#define iter_remove_us(%1,%2); %1@t=%2;iter_remove(%1,%1@t)
#define iter_has(%1,%2) (%1@h[%2])
#define iter_clear(%1) for(new t@%1=0;t@%1<%1@c;t@%1++){%1@h[%1[t@%1]]=0;}%1@c=0
#define iter_count(%1) (%1@c)
#define iter_random(%1) (%1[random(%1@c)])
//#define for%0\32(new%0\32%1:%2) for(new m@%1=%2@c,%1;(m@%1>0)|(m@%1>0&&(%1=%2[m@%1-1]));m@%1--)
//#define for%0\32(new%0\32%1:%2) for(new %1=%2@c-1;%1>=0;%1--)
#define for%0\32(new%0\32%1:%2) for(new %1=0;%1<%2@c;%1++)
#define iter_access(%1,%2) (%1[%2])

