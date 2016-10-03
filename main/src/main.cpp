#include <iostream>

#include "TestObject.h"


int main( int argc, char* argv[] )
{
	TestObject obj;
	std::cout << obj.publicFunction() << std::endl;
	//std::cout << privateFunction() << std::endl;
	return 0;
}