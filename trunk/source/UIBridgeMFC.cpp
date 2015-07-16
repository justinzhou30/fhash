#include "stdafx.h"

#include "UIBridgeMFC.h"

#include <stdlib.h>
#include <Windows.h>

#include "strhelper.h"
#include "OsUtils/OsThread.h"

#include "Global.h"
#include "UIStrings.h"

using namespace sunjwbase;

extern OsMutex g_mainMtx;

UIBridgeMFC::UIBridgeMFC(HWND hWnd, 
						ThreadData *threadData,
						sunjwbase::tstring *tstrUIAll)
:m_hWnd(hWnd), m_thrdData(threadData), m_uiTstrAll(tstrUIAll)
{
}

UIBridgeMFC::~UIBridgeMFC()
{
}

void UIBridgeMFC::preparingCalc()
{
	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_WORKING, 0);
	
	g_mainMtx.lock();
	{
		m_tstrNoPreparing = *m_uiTstrAll;
		m_uiTstrAll->append(MAINDLG_WAITING_START);
		m_uiTstrAll->append(_T("\r\n"));
	}
	g_mainMtx.unlock();
	
	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_REFRESH_TEXT, 0);
}

void UIBridgeMFC::removePreparingCalc()
{
	g_mainMtx.lock();
	{
		// restore and remove MAINDLG_WAITING_START
		*m_uiTstrAll = m_tstrNoPreparing;
	}
	g_mainMtx.unlock();
}

void UIBridgeMFC::calcStop()
{
	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_STOPPED, 0);
}

void UIBridgeMFC::calcFinish()
{
	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_FINISHED, 0);
}

void UIBridgeMFC::showFileName(const tstring& tstrFileName)
{
	g_mainMtx.lock();
	{
		m_uiTstrAll->append(FILENAME_STRING);
		m_uiTstrAll->append(_T(" "));
		m_uiTstrAll->append(tstrFileName);
		m_uiTstrAll->append(_T("\r\n"));
	}
	g_mainMtx.unlock();

	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_REFRESH_TEXT, 0);
}

void UIBridgeMFC::showFileMeta(const tstring& tstrFileSize,
							const tstring& tstrShortSize,
							const tstring& tstrLastModifiedTime,
							const tstring& tstrFileVersion)
{
	g_mainMtx.lock();
	{
		m_uiTstrAll->append(FILESIZE_STRING);
		m_uiTstrAll->append(_T(" "));
		m_uiTstrAll->append(tstrFileSize);
		m_uiTstrAll->append(_T(" "));
		m_uiTstrAll->append(BYTE_STRING);
		m_uiTstrAll->append(tstrShortSize);
		m_uiTstrAll->append(_T("\r\n"));
		m_uiTstrAll->append(MODIFYTIME_STRING);
		m_uiTstrAll->append(_T(" "));
		m_uiTstrAll->append(tstrLastModifiedTime);

		if(tstrFileVersion != _T(""))
		{
			m_uiTstrAll->append(_T("\r\n"));
			m_uiTstrAll->append(VERSION_STRING);
			m_uiTstrAll->append(_T(" "));
			m_uiTstrAll->append(tstrFileVersion);
		}

		m_uiTstrAll->append(_T("\r\n"));
	}
	g_mainMtx.unlock();
	
	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_REFRESH_TEXT, 0);
}

void UIBridgeMFC::showFileHash(const tstring& tstrFileMD5,
							const tstring& tstrFileSHA1,
							const tstring& tstrFileSHA256,
							const tstring& tstrFileCRC32)
{
	g_mainMtx.lock();
	{
		m_uiTstrAll->append(_T("MD5: "));
		m_uiTstrAll->append(tstrFileMD5);
		m_uiTstrAll->append(_T("\r\nSHA1: "));
		m_uiTstrAll->append(tstrFileSHA1);
		m_uiTstrAll->append(_T("\r\nSHA256: "));
		m_uiTstrAll->append(tstrFileSHA256);
		m_uiTstrAll->append(_T("\r\nCRC32: "));
		m_uiTstrAll->append(tstrFileCRC32);
		m_uiTstrAll->append(_T("\r\n\r\n"));
	}
	g_mainMtx.unlock();

	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_REFRESH_TEXT, 0);
}

void UIBridgeMFC::showFileErr(const tstring& tstrErr)
{
	g_mainMtx.lock();
	{
		m_uiTstrAll->append(tstrErr);
		m_uiTstrAll->append(_T("\r\n\r\n"));
	}
	g_mainMtx.unlock();

	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_REFRESH_TEXT, 0);
}

int UIBridgeMFC::getProgMax()
{
	return 100;
}

void UIBridgeMFC::updateProg(int value)
{
	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_PROG, value);
}

void UIBridgeMFC::updateProgWhole(int value)
{
	::PostMessage(m_hWnd, WM_THREAD_INFO, WP_PROG_WHOLE, value);
}

void UIBridgeMFC::fileCalcFinish()
{
}

void UIBridgeMFC::fileFinish()
{
}
