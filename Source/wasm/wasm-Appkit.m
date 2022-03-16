
#import "wasm-Appkit.h"


static BOOL g_isCreatingNSWindowForImageCache = 0;

void _setCreatingNSWindowForImageCache(BOOL flag)
{
	g_isCreatingNSWindowForImageCache = flag;
}

BOOL _isCreatingNSWindowForImageCache()
{
	return g_isCreatingNSWindowForImageCache;
}