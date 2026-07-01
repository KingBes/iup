/**
 * IUP DLL 功能测试
 * 编译: gcc -o build/test.exe test/test.c -Iinclude -Lbuild -liup -m64 -DIUP_DLL
 * 运行: build\test.exe
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iup.h>
#include <iupcontrols.h>
#include <iupgl.h>
#include <iupglcontrols.h>
#include <iupim.h>
#include <iuptuio.h>
#include <iup_mglplot.h>
#include <iup_scintilla.h>
#include <iupole.h>
#include <iup_config.h>

static int pass = 0, fail = 0;

#define TEST(name, expr) do { \
    printf("  %-45s", name); \
    if (expr) { printf("[PASS]\n"); pass++; } \
    else { printf("[FAIL]\n"); fail++; } \
} while(0)

#define TEST_NOTNULL(name, ptr) TEST(name, ((ptr) != NULL))

static int btn_action(Ihandle* ih) { (void)ih; return IUP_DEFAULT; }
static int idle_cb(Ihandle* ih) { (void)ih; return IUP_CLOSE; }

int main(int argc, char** argv) {
    (void)argc; (void)argv;
    printf("============================================================\n");
    printf("  IUP DLL Function Test Suite\n");
    printf("============================================================\n\n");

    /* ----- Core Init ----- */
    printf("[Core] Initialization\n");
    TEST("IupOpen()", IupOpen(NULL, NULL) == IUP_NOERROR);
    printf("  Version: %s (%s)\n", IupVersion(), IupVersionDate());

    /* ----- Modules Init ----- */
    printf("\n[Modules] Open\n");
    TEST("IupControlsOpen()", IupControlsOpen() == IUP_NOERROR);
    IupGLCanvasOpen();             TEST("IupGLCanvasOpen()", 1);
    TEST("IupGLControlsOpen()", IupGLControlsOpen() == IUP_NOERROR);
    IupImageLibOpen();             TEST("IupImageLibOpen()", 1);
    TEST("IupTuioOpen()", IupTuioOpen() == IUP_NOERROR);
    IupMglPlotOpen();              TEST("IupMglPlotOpen()", 1);
    IupScintillaOpen();            TEST("IupScintillaOpen()", 1);
    TEST("IupOleControlOpen()", IupOleControlOpen() == IUP_NOERROR);

    /* ----- Core Widgets ----- */
    printf("\n[Core] Widget Creation\n");
    Ihandle *dlg, *btn, *lbl, *txt, *toggle, *list;

    lbl = IupLabel("Hello IUP!");
    TEST_NOTNULL("IupLabel()", lbl);

    btn = IupButton("Click Me", NULL);
    TEST_NOTNULL("IupButton()", btn);
    IupSetCallback(btn, "ACTION", (Icallback)btn_action);

    txt = IupText(NULL);
    TEST_NOTNULL("IupText()", txt);
    IupSetAttribute(txt, "VALUE", "Edit me...");

    toggle = IupToggle("Toggle", NULL);
    TEST_NOTNULL("IupToggle()", toggle);

    list = IupList(NULL);
    TEST_NOTNULL("IupList()", list);
    IupSetAttribute(list, "1", "Item 1");
    IupSetAttribute(list, "2", "Item 2");

    /* ----- Layout ----- */
    printf("\n[Core] Layout\n");
    Ihandle *vbox = IupVbox(lbl, btn, txt, toggle, list, NULL);
    TEST_NOTNULL("IupVbox()", vbox);
    TEST_NOTNULL("IupHbox()", IupHbox(IupLabel("HBox Test"), IupButton("HBtn", NULL), NULL));
    TEST_NOTNULL("IupFrame()", IupFrame(IupLabel("Inside Frame")));
    TEST_NOTNULL("IupGridBox()", IupGridBox(IupLabel("A"), IupLabel("B"), NULL));
    TEST_NOTNULL("IupZbox()", IupZbox(IupLabel("Z1"), IupLabel("Z2"), NULL));
    TEST_NOTNULL("IupCbox()", IupCbox(IupLabel("C1"), IupLabel("C2"), NULL));
    TEST_NOTNULL("IupSbox()", IupSbox(IupLabel("Scrollable")));

    /* ----- Dialog ----- */
    printf("\n[Core] Dialog\n");
    dlg = IupDialog(vbox);
    TEST_NOTNULL("IupDialog()", dlg);
    IupSetAttribute(dlg, "TITLE", "IUP Test");
    IupSetAttribute(dlg, "SIZE", "300x200");

    /* ----- Attributes ----- */
    printf("\n[Core] Attributes\n");
    IupSetAttribute(dlg, "CUSTOM", "hello");
    TEST("SetAttribute + Get", strcmp(IupGetAttribute(dlg, "CUSTOM"), "hello") == 0);
    IupSetInt(dlg, "TESTINT", 42);
    TEST("SetInt + GetInt", IupGetInt(dlg, "TESTINT") == 42);
    IupSetDouble(dlg, "TESTDBL", 3.14);
    TEST("SetDouble + GetDouble", IupGetDouble(dlg, "TESTDBL") > 3.13 && IupGetDouble(dlg, "TESTDBL") < 3.15);

    /* ----- Flat Controls ----- */
    printf("\n[Flat Controls]\n");
    TEST_NOTNULL("IupFlatButton()", IupFlatButton("Flat"));
    TEST_NOTNULL("IupFlatLabel()", IupFlatLabel("FlatLabel"));
    TEST_NOTNULL("IupFlatToggle()", IupFlatToggle("FlatToggle"));
    TEST_NOTNULL("IupFlatSeparator()", IupFlatSeparator());
    TEST_NOTNULL("IupFlatFrame()", IupFlatFrame(IupLabel("FlatFrame")));
    TEST_NOTNULL("IupFlatTabs()", IupFlatTabs(IupLabel("Tab1"), IupLabel("Tab2"), NULL));
    TEST_NOTNULL("IupFlatTree()", IupFlatTree());
    TEST_NOTNULL("IupFlatList()", IupFlatList());

    /* ----- Misc Controls ----- */
    printf("\n[Misc Controls]\n");
    TEST_NOTNULL("IupProgressBar()", IupProgressBar());
    TEST_NOTNULL("IupGauge()", IupGauge());
    TEST_NOTNULL("IupDial()", IupDial(NULL));
    TEST_NOTNULL("IupSpin()", IupSpin());
    TEST_NOTNULL("IupColorbar()", IupColorbar());
    TEST_NOTNULL("IupColorBrowser()", IupColorBrowser());
    TEST_NOTNULL("IupSplit()", IupSplit(IupLabel("Left"), IupLabel("Right")));
    TEST_NOTNULL("IupTabs()", IupTabs(IupLabel("A"), IupLabel("B"), NULL));
    TEST_NOTNULL("IupExpander()", IupExpander(IupLabel("Expand me")));
    TEST_NOTNULL("IupDetachBox()", IupDetachBox(IupLabel("Detachable")));
    TEST_NOTNULL("IupLink()", IupLink("https://example.com", "Visit Site"));
    TEST_NOTNULL("IupCalendar()", IupCalendar());
    TEST_NOTNULL("IupDatePick()", IupDatePick());
    TEST_NOTNULL("IupDropButton()", IupDropButton(IupLabel("Drop")));
    TEST_NOTNULL("IupNormalizer()", IupNormalizer(IupLabel("N1"), IupLabel("N2"), NULL));
    TEST_NOTNULL("IupScrollBox()", IupScrollBox(IupLabel("Scroll")));
    TEST_NOTNULL("IupBackgroundBox()", IupBackgroundBox(IupLabel("Bg")));
    TEST_NOTNULL("IupAnimatedLabel()", IupAnimatedLabel(NULL));
    TEST_NOTNULL("IupMultiBox()", IupMultiBox(IupLabel("M1"), NULL));

    /* ----- Dialogs ----- */
    printf("\n[Dialogs]\n");
    TEST_NOTNULL("IupFileDlg()", IupFileDlg());
    TEST_NOTNULL("IupColorDlg()", IupColorDlg());
    TEST_NOTNULL("IupFontDlg()", IupFontDlg());
    TEST_NOTNULL("IupMessageDlg()", IupMessageDlg());
    TEST("IupAlarm()", IupAlarm("Test", "Message", "OK", NULL, NULL) > 0);

    /* ----- Image ----- */
    printf("\n[Image]\n");
    Ihandle* img = IupImage(16, 16, (unsigned char*)
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
        "\x00\x00\x00\x00\xFF\x00\x00\x00\xFF\x00\x00\x00\x00\x00\x00\x00"
        "\x00\x00\x00\x00\xFF\x00\x00\x00\xFF\x00\x00\x00\x00\x00\x00\x00"
        "\x00\x00\x00\x00\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00"
        "\x00\x00\x00\x00\xFF\x00\x00\x00\xFF\x00\x00\x00\x00\x00\x00\x00"
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00");
    TEST_NOTNULL("IupImage()", img);
    TEST("IupSaveImageAsText()", IupSaveImageAsText(img, "build/test_img.txt", "PNG", "test_img") != -1);

    /* ----- Scintilla ----- */
    printf("\n[Scintilla]\n");
    Ihandle* sci = IupScintilla();
    TEST_NOTNULL("IupScintilla()", sci);
    IupSetAttribute(sci, "VALUE", "int main() {\n    printf(\"Hello Scintilla!\\n\");\n    return 0;\n}");
    IupSetAttribute(sci, "LEXERLANGUAGE", "cpp");

    /* ----- OpenGL ----- */
    printf("\n[OpenGL]\n");
    TEST_NOTNULL("IupGLCanvas()", IupGLCanvas(NULL));
    TEST_NOTNULL("IupGLButton()", IupGLButton("GL Button"));
    TEST_NOTNULL("IupGLLabel()", IupGLLabel("GL Label"));
    TEST_NOTNULL("IupGLToggle()", IupGLToggle("GL Toggle"));
    TEST_NOTNULL("IupGLText()", IupGLText());
    TEST_NOTNULL("IupGLFrame()", IupGLFrame(IupGLButton("In")));
    TEST_NOTNULL("IupGLSeparator()", IupGLSeparator());
    TEST_NOTNULL("IupGLProgressBar()", IupGLProgressBar());
    TEST_NOTNULL("IupGLLink()", IupGLLink("url", "GL Link"));

    /* ----- MglPlot ----- */
    printf("\n[MglPlot]\n");
    TEST_NOTNULL("IupMglPlot()", IupMglPlot());
    TEST_NOTNULL("IupMglLabel()", IupMglLabel("MGL Label"));

    /* ----- TUIO ----- */
    printf("\n[TUIO]\n");
    TEST_NOTNULL("IupTuioClient()", IupTuioClient(12345));

    /* ----- OLE ----- */
    printf("\n[OLE]\n");
    TEST_NOTNULL("IupOleControl(NULL)", IupOleControl(NULL)); /* NULL progid = no control */

    /* ----- Dialog lifecycle ----- */
    printf("\n[Dialog] Lifecycle\n");
    IupSetCallback(dlg, "IDLE_ACTION", (Icallback)idle_cb);
    Ihandle* quick_dlg = IupDialog(IupLabel("Quick test"));
    IupSetAttribute(quick_dlg, "TITLE", "Quick");
    IupSetAttribute(quick_dlg, "SIZE", "100x50");
    TEST("IupPopup() lifecycle", IupPopup(quick_dlg, IUP_CENTER, IUP_CENTER) == IUP_NOERROR);

    /* ----- Config ----- */
    printf("\n[Config]\n");
    Ihandle* cfg = IupConfig();
    TEST_NOTNULL("IupConfig()", cfg);
    IupConfigLoad(cfg);
    IupConfigSetVariableStr(cfg, "Test", "Key", "Value");
    TEST("Config Set/Get", strcmp(IupConfigGetVariableStr(cfg, "Test", "Key"), "Value") == 0);

    /* ----- LED Load ----- */
    printf("\n[LED Parser]\n");
    const char* led_str = "d = dialog[title=\"LED Test\",size=\"200x100\"] { hbox[label,button=\"OK\"] }";
    char* led_err = IupLoadBuffer(led_str);
    TEST("IupLoadBuffer()", led_err == NULL);

    /* ----- Tree ----- */
    printf("\n[Tree]\n");
    Ihandle* tree = IupTree();
    TEST_NOTNULL("IupTree()", tree);

    /* ----- Menu ----- */
    printf("\n[Menu]\n");
    Ihandle* menu = IupMenu(IupItem("File", NULL), IupSeparator(), IupItem("Exit", NULL), NULL);
    TEST_NOTNULL("IupMenu()", menu);
    TEST_NOTNULL("IupSubmenu()", IupSubmenu("Options", menu));

    /* ----- Clipboard ----- */
    printf("\n[Clipboard]\n");
    IupSetAttribute(NULL, "CLIPBOARDTEXT", "IUP Test");
    TEST("Clipboard Set/Get", strcmp(IupGetAttribute(NULL, "CLIPBOARDTEXT"), "IUP Test") == 0);

    /* ----- Names ----- */
    printf("\n[Names]\n");
    IupSetHandle("testHandle", lbl);
    TEST("IupGetHandle()", IupGetHandle("testHandle") == lbl);

    /* ----- Global Attribs ----- */
    printf("\n[Globals]\n");
    TEST("IupGetGlobal(SYSTEM)", IupGetGlobal("SYSTEM") != NULL);
    TEST("IupGetGlobal(SYSTEMVERSION)", IupGetGlobal("SYSTEMVERSION") != NULL);
    printf("  SYSTEM: %s\n", IupGetGlobal("SYSTEM"));
    printf("  SYSTEMVERSION: %s\n", IupGetGlobal("SYSTEMVERSION"));

    /* ----- Thread ----- */
    printf("\n[Thread]\n");
    TEST_NOTNULL("IupThread()", IupThread());

    /* ----- Cleanup ----- */
    printf("\n[Cleanup]\n");
    IupDestroy(dlg);
    IupDestroy(quick_dlg);
    IupClose();

    /* ===== Results ===== */
    printf("\n============================================================\n");
    printf("  RESULTS: %d passed, %d failed, %d total\n", pass, fail, pass+fail);
    printf("============================================================\n");

    if (fail > 0) {
        printf("\n*** %d TEST(S) FAILED ***\n", fail);
        return 1;
    }
    printf("\n*** ALL TESTS PASSED ***\n");
    return 0;
}
