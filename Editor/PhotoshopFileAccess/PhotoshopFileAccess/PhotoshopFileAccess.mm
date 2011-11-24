#include "PhotoshopFileAccess.h"
#include "SoSharedLibDefs.h"
#include <stdio.h>

FILE* file = NULL;

PhotoshopFileAccess_API long _remove(TaggedData* argv, long argc, TaggedData* retval) {
    remove(argv[0].data.string);
	return kESErrOK;
}

PhotoshopFileAccess_API long _fopen(TaggedData* argv, long argc, TaggedData* retval) {
    file = fopen(argv[0].data.string, argv[1].data.string);
	return kESErrOK;
}

PhotoshopFileAccess_API long _fclose(TaggedData* argv, long argc, TaggedData* retval) {
    fclose(file);
	return kESErrOK;
}

PhotoshopFileAccess_API long _fwriteString(TaggedData* argv, long argc, TaggedData* retval) {
    fwrite(argv[0].data.string, sizeof(char), strlen(argv[0].data.string), file);
	return kESErrOK;
}

PhotoshopFileAccess_API long _fwriteFloat(TaggedData* argv, long argc, TaggedData* retval) {
    float value = argv[0].data.fltval;
    fwrite(&value, sizeof(float), 1, file);
	return kESErrOK;
}

PhotoshopFileAccess_API long _fwriteInt(TaggedData* argv, long argc, TaggedData* retval) {
    int value = (int)argv[0].data.fltval;
    fwrite(&value, sizeof(int), 1, file);
	return kESErrOK;
}

PhotoshopFileAccess_API long ESGetVersion() {
	return 0x1;
}

PhotoshopFileAccess_API char* ESInitialize (const TaggedData** argv, long argc) { 
	return (char*)"_remove,_fopen,_fclose,_fwriteString,_fwriteFloat,_fwriteInt";
}

PhotoshopFileAccess_API void ESTerminate() {
	
}

PhotoshopFileAccess_API void* ESMallocMem(size_t nBytes) {
	void* p = malloc(nBytes);
	return p ;
}

PhotoshopFileAccess_API void ESFreeMem(void* p) { 
	delete (char*)(p);
}