/* 
Shit to mess with:
Change SCE_L2 to ctrl.lt
Remove L2/R2 Function if game already has it bound
Try do away with Emulated Touch functions - Make sure it works properly though
Fix Font loading error -- Add to first while loop maybe?
General Optimisation, E.G make sure using correct int datatypes -- Do this last
*/

#include <psp2/kernel/modulemgr.h>
#include <psp2/kernel/processmgr.h>
#include <psp2/touch.h>
#include <psp2/ctrl.h>
#include <psp2/io/fcntl.h>
#include <stdio.h>

#include <taihen.h>
#define HOOKS_NUM 1

#define MULTITOUCH_FRONT_NUM 6
#define MULTITOUCH_REAR_NUM 4

static uint8_t current_hook = 0;
static SceUID hooks[HOOKS_NUM];
static tai_hook_ref_t refs[HOOKS_NUM];

static char buffer[32];
static uint16_t l2x, l2y, r2x, r2y; 

SceCtrlData ctrl;

void loadConfig(void) {
	int fd = sceIoOpen("ux0:data/TriggerRemap.txt", SCE_O_RDWR, 0777);
	if (fd >= 0){
		sceIoRead(fd, buffer, 32);
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

typedef struct EmulatedTouch{
	SceTouchReport reports[MULTITOUCH_FRONT_NUM];
	uint8_t num;
}EmulatedTouch;
EmulatedTouch etFront, etRear, prevEtFront, prevEtRear;
static uint8_t etFrontIdCounter = 64;
static uint8_t etRearIdCounter = 64;
static uint16_t TOUCH_SIZE[4] = {
	1920, 1088,	//Front
	1919, 890	//Rear
};

void storeTouchPoint(EmulatedTouch *et, int16_t x, int16_t y){
	for (int i = 0; i < et->num; i++)
		if (et->reports[i].x == x && et->reports[i].y == y)
			return;
	et->reports[et->num].x = x;
	et->reports[et->num].y = y;
	et->num++;
}

uint8_t generateTouchId(int x, int y, int panel){ 
	if (panel == SCE_TOUCH_PORT_FRONT){
		for (int i = 0; i < prevEtFront.num; i++)
			if (prevEtFront.reports[i].x == x && prevEtFront.reports[i].y == y)
				return prevEtFront.reports[i].id;
		etFrontIdCounter = (etFrontIdCounter + 1) % 127;
		return etFrontIdCounter;
	} else {
		for (int i = 0; i < prevEtRear.num; i++)
			if (prevEtRear.reports[i].x == x && prevEtRear.reports[i].y == y)
				return prevEtRear.reports[i].id;
		etRearIdCounter = (etRearIdCounter + 1) % 127;
		return etRearIdCounter;
	}
}

void addVirtualTouches(SceTouchData *pData, EmulatedTouch *et, uint8_t touchPointsMaxNum, int panel){
	int touchIdx = 0;
	while (touchIdx < et->num && pData->reportNum < touchPointsMaxNum){
		pData->report[pData->reportNum].x = et->reports[touchIdx].x;
		pData->report[pData->reportNum].y = et->reports[touchIdx].y;
		et->reports[touchIdx].id = generateTouchId(
			et->reports[touchIdx].x, et->reports[touchIdx].y, panel);
		pData->report[pData->reportNum].id = et->reports[touchIdx].id;
		pData->reportNum ++;
		touchIdx ++;
	}
}

int sceTouchPeek_patched(SceUInt32 port, SceTouchData *pData, SceUInt32 nBufs){
	int ret = TAI_CONTINUE(int, refs[0], port, pData, nBufs);
	//if (port == SCE_TOUCH_PORT_BACK) pData->reportNum = 0;

	sceCtrlPeekBufferPositiveExt2(0, &ctrl, 1);
	if((ctrl.buttons == SCE_CTRL_R2) | (ctrl.buttons & SCE_CTRL_R2)) {
		storeTouchPoint(&etRear, r2x, r2y);
	}

	// if((ctrl.buttons == SCE_CTRL_L2) | (ctrl.buttons & SCE_CTRL_L2)) {
	// 	pData->report->id = 2;
	// 	pData->report->x = l2x;
	// 	pData->report->y = l2y;
	// }

	addVirtualTouches(pData, &etRear, MULTITOUCH_REAR_NUM, SCE_TOUCH_PORT_BACK);
	prevEtRear = etRear;
	etRear.num = 0;

	return ret;

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