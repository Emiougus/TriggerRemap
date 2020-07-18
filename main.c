#include <psp2/kernel/modulemgr.h>
#include <psp2/kernel/processmgr.h>
#include <psp2/touch.h>
#include <psp2/ctrl.h>
#include <psp2/io/fcntl.h>
#include <stdio.h>

#include <taihen.h>
#define HOOKS_NUM 1

static uint8_t current_hook = 0;
static SceUID hooks[HOOKS_NUM];
static tai_hook_ref_t refs[HOOKS_NUM];

static char buffer[33];
static uint16_t l2x, l2y, r2x, r2y; 
static uint8_t rearId = 64;

SceCtrlData ctrl;

void loadConfig(void) {
	int fd = sceIoOpen("ux0:data/TriggerRemap.txt", SCE_O_RDWR, 0777);
	if (fd >= 0){
		sceIoRead(fd, buffer, 33);
		sceIoClose(fd);
	} else { 
		sprintf(buffer, "L2=X:500,Y:350;R2=X:1300,Y:350"); 
	}
	sscanf(buffer, "L2=X:%hu,Y:%hu;R2=X:%hu,Y:%hu", &l2x, &l2y, &r2x, &r2y);
}

void hookFunction(uint32_t nid, const void *func){
	hooks[current_hook] = taiHookFunctionImport(&refs[current_hook],TAI_MAIN_MODULE,TAI_ANY_LIBRARY,nid,func);
	current_hook++;
}

int sceTouchPeek_patched(SceUInt32 port, SceTouchData *pData, SceUInt32 nBufs){
	int ret = TAI_CONTINUE(int, refs[0], port, pData, nBufs);

	sceCtrlPeekBufferPositiveExt2(0, &ctrl, 1);
	if((ctrl.buttons == SCE_CTRL_R2) | (ctrl.buttons & SCE_CTRL_R2)) {
		port = SCE_TOUCH_PORT_BACK;
		pData->report[pData->reportNum].x = r2x;
		pData->report[pData->reportNum].y = r2y;
		pData->report[pData->reportNum].id = (rearId + 1) % 127;
		pData->reportNum ++;
	}

	if((ctrl.buttons == SCE_CTRL_L2) | (ctrl.buttons & SCE_CTRL_L2)) {
		port = SCE_TOUCH_PORT_BACK;
		pData->report[pData->reportNum].x = l2x;
		pData->report[pData->reportNum].y = l2y;
		pData->report[pData->reportNum].id = (rearId + 1) % 127;
		pData->reportNum ++;
	}

	return ret;
	pData->reportNum = 0;

}

void _start() __attribute__ ((weak, alias ("module_start")));
int module_start(SceSize argc, const void *args) {
	
	//Load Config
	loadConfig();
	
	// Hooking touch functions
	hookFunction(0xFF082DF0, sceTouchPeek_patched);

	return SCE_KERNEL_START_SUCCESS;
}

int module_stop(SceSize argc, const void *args) {

	// Freeing hooks
	while (current_hook-- > 0){
		taiHookRelease(hooks[current_hook], refs[current_hook]);
	}

	return SCE_KERNEL_STOP_SUCCESS;
	
}
