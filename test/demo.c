/**
 * IUP DLL GUI 演示程序
 * 编译: gcc -o build/demo.exe test/demo.c -Iinclude -Lbuild -liup -m64 -DIUP_DLL
 */
#include <stdlib.h>
#include <stdio.h>
#include <iup.h>
#include <iupcontrols.h>
#include <iupgl.h>
#include <iupglcontrols.h>
#include <iupim.h>
#include <iup_scintilla.h>
#include <iup_mglplot.h>

/* ====== Callbacks ====== */
static int btn_click(Ihandle* ih) {
    (void)ih;
    IupMessage("Hello", "Button clicked!");
    return IUP_DEFAULT;
}

static int exit_cb(Ihandle* ih) {
    (void)ih;
    return IUP_CLOSE;
}

static int toggle_cb(Ihandle* ih, int state) {
    printf("Toggle: %s\n", state ? "ON" : "OFF");
    return IUP_DEFAULT;
}

static int list_cb(Ihandle* ih, char* text, int item, int state) {
    if (state == 1)
        printf("Selected: %s (item %d)\n", text, item);
    return IUP_DEFAULT;
}

static int tabs_change(Ihandle* ih, Ihandle* new_tab, Ihandle* old_tab) {
    (void)old_tab;
    printf("Tab changed to: %d\n", IupGetInt(ih, "VALUEPOS"));
    return IUP_DEFAULT;
}

int main(void) {
    IupOpen(NULL, NULL);
    IupControlsOpen();
    IupGLCanvasOpen();
    IupGLControlsOpen();
    IupImageLibOpen();
    IupScintillaOpen();
    IupMglPlotOpen();

    /* ===== Tab 1: Basic Widgets ===== */
    Ihandle *name_label = IupLabel("Name:");
    Ihandle *name_text  = IupText(NULL);
    IupSetAttribute(name_text, "SIZE", "120x");
    IupSetAttribute(name_text, "VALUE", "Type here...");

    Ihandle *btn1 = IupButton("Click Me!", NULL);
    IupSetCallback(btn1, "ACTION", (Icallback)btn_click);

    Ihandle *toggle = IupToggle("Enable Feature", NULL);
    IupSetCallback(toggle, "VALUECHANGED_CB", (Icallback)toggle_cb);

    Ihandle *list = IupList(NULL);
    IupSetAttribute(list, "1", "Option A");
    IupSetAttribute(list, "2", "Option B");
    IupSetAttribute(list, "3", "Option C");
    IupSetAttribute(list, "DROPDOWN", "YES");
    IupSetAttribute(list, "VALUE", "1");
    IupSetCallback(list, "ACTION", (Icallback)list_cb);

    Ihandle *progress = IupProgressBar();
    IupSetAttribute(progress, "VALUE", "65");

    Ihandle *spin = IupSpin();
    IupSetAttribute(spin, "VALUE", "42");
    IupSetAttribute(spin, "MIN", "0");
    IupSetAttribute(spin, "MAX", "100");

    Ihandle *colorbar = IupColorbar();
    IupSetAttribute(colorbar, "VALUE", "128 0 255");
    IupSetAttribute(colorbar, "SIZE", "60x20");
    IupSetAttribute(colorbar, "SHOWHEX", "YES");
    IupSetAttribute(colorbar, "PREVIEW_SIZE", "20");

    Ihandle *calendar = IupCalendar();

    Ihandle *datepick = IupDatePick();

    Ihandle *link = IupLink("https://github.com", "GitHub");

    Ihandle *expand = IupExpander(
        IupSetAttributes(IupLabel("Extra options"), "TITLE=Details"));

    /* 基本控件布局 */
    Ihandle *tab1 = IupVbox(
        IupSetAttributes(IupFrame(
            IupVbox(
                IupSetAttributes(IupHbox(name_label, name_text, NULL), "GAP=5"),
                IupSetAttributes(IupHbox(
                    IupLabel("Range:"), spin,
                    IupLabel("Progress:"), progress,
                    NULL), "GAP=8,MARGIN=8x4"),
                IupSetAttributes(IupHbox(btn1, toggle, NULL), "GAP=10,MARGIN=5x4"),
                NULL)), "TITLE=Input Controls"),
        IupHbox(
            IupSetAttributes(IupFrame(
                IupVbox(list, colorbar, NULL)), "TITLE=Selection"),
            IupSetAttributes(IupFrame(
                IupVbox(calendar, NULL)), "TITLE=Calendar"),
            IupSetAttributes(IupFrame(
                IupVbox(datepick, link, expand, NULL)), "TITLE=More"),
            IupFill(),
            NULL),
        NULL);

    /* ===== Tab 2: Code Editor (Scintilla) ===== */
    Ihandle *sci = IupScintilla();
    IupSetAttribute(sci, "VALUE",
        "// IUP Scintilla Demo\n"
        "#include <stdio.h>\n\n"
        "int main() {\n"
        "    printf(\"Hello, IUP!\\n\");\n"
        "    return 0;\n"
        "}\n");
    IupSetAttribute(sci, "EXPAND", "YES");
    IupSetAttribute(sci, "LEXERLANGUAGE", "cpp");
    IupSetAttribute(sci, "STYLEFGCOLOR34", "255 0 0");     /* operators red */
    IupSetAttribute(sci, "STYLEFGCOLOR5", "0 0 255");      /* keywords blue */
    IupSetAttribute(sci, "STYLEFGCOLOR6", "0 128 0");      /* strings green */
    IupSetAttribute(sci, "STYLEFGCOLOR4", "128 128 128");  /* comments grey */
    IupSetAttribute(sci, "CARETFGCOLOR", "255 255 255");
    IupSetAttribute(sci, "CARETLINEVISIBLE", "YES");
    IupSetAttribute(sci, "CARETLINEBACK", "40 40 48");
    IupSetAttribute(sci, "MARGINWIDTH0", "40");

    Ihandle *tab2 = sci;

    /* ===== Tab 3: Flat Controls ===== */
    Ihandle *flat_btn    = IupFlatButton("Flat Button");
    Ihandle *flat_toggle = IupSetAttributes(IupFlatToggle("Toggle"), "VALUE=ON");
    Ihandle *flat_label  = IupSetAttributes(IupFlatLabel("Flat Label"), "FGCOLOR=0 128 0");
    Ihandle *flat_sep    = IupFlatSeparator();
    Ihandle *flat_gauge  = IupGauge();
    IupSetAttribute(flat_gauge, "VALUE", "0.75");
    Ihandle *flat_dial   = IupDial("Dial");
    IupSetAttribute(flat_dial, "VALUE", "120");
    IupSetAttribute(flat_dial, "MIN", "0");
    IupSetAttribute(flat_dial, "MAX", "360");

    Ihandle *tab3 = IupVbox(
        IupSetAttributes(IupHbox(flat_btn, flat_toggle, flat_label, flat_sep, NULL),
                         "GAP=10,MARGIN=10x10"),
        IupSetAttributes(IupHbox(
            IupFrame(IupSetAttributes(flat_gauge, "TITLE=Gauge")),
            IupFrame(IupSetAttributes(flat_dial, "TITLE=Dial")),
            IupFill(), NULL), "GAP=10,MARGIN=10x5"),
        IupFrame(IupFlatTabs(
            IupFlatButton("SubTab A"),
            IupFlatButton("SubTab B"),
            IupFlatToggle("SubTab C"),
            NULL)),
        NULL);

    /* ===== Tab 4: OpenGL ===== */
    Ihandle *gl_canvas = IupGLCanvas(NULL);
    IupSetAttribute(gl_canvas, "SIZE", "200x150");
    IupSetAttribute(gl_canvas, "BUFFER", "DOUBLE");

    Ihandle *tab4 = IupVbox(
        IupSetAttributes(IupHbox(
            IupLabel("OpenGL Canvas Demo"),
            IupFill(), NULL), "MARGIN=8x4"),
        IupFrame(gl_canvas),
        IupFill(),
        NULL);

    /* ===== Tab 5: Tree ===== */
    Ihandle *tree = IupTree();
    IupSetAttribute(tree, "ADDROOT", "Project");
    IupSetAttribute(tree, "ADDBRANCH1", "src");
    IupSetAttribute(tree, "ADDLEAF1_1", "main.c");
    IupSetAttribute(tree, "ADDLEAF1_2", "utils.c");
    IupSetAttribute(tree, "ADDBRANCH2", "include");
    IupSetAttribute(tree, "ADDLEAF2_1", "iup.h");
    IupSetAttribute(tree, "ADDLEAF2_2", "iupcontrols.h");
    IupSetAttribute(tree, "ADDBRANCH3", "resources");
    IupSetAttribute(tree, "ADDLEAF3_1", "icon.png");
    IupSetAttribute(tree, "EXPAND", "YES");

    Ihandle *tab5 = IupFrame(IupSetAttributes(tree, "TITLE=File Browser"));

    /* ===== Tab 6: Plot ===== */
    Ihandle *plot = IupMglPlot();
    IupSetAttribute(plot, "SIZE", "300x200");
    IupSetAttribute(plot, "TITLE", "Sine Wave Demo");
    IupSetAttribute(plot, "XLABEL", "X Axis");
    IupSetAttribute(plot, "YLABEL", "Y Axis");
    IupSetAttribute(plot, "GRID", "YES");
    IupSetAttribute(plot, "LEGEND", "YES");
    IupSetAttribute(plot, "AXS_XLABELCENTERED", "YES");

    Ihandle *tab6 = IupVbox(
        IupSetAttributes(IupHbox(
            IupLabel("MathGL 3D/2D Plot Demo"),
            IupFill(), NULL), "MARGIN=8x4"),
        IupFrame(plot),
        IupFill(), NULL);

    /* ===== Tab Container ===== */
    Ihandle *tabs = IupTabs(tab1, tab2, tab3, tab4, tab5, tab6, NULL);
    IupSetAttribute(tabs, "TABTITLE0", "Controls");
    IupSetAttribute(tabs, "TABTITLE1", "Code Editor");
    IupSetAttribute(tabs, "TABTITLE2", "Flat UI");
    IupSetAttribute(tabs, "TABTITLE3", "OpenGL");
    IupSetAttribute(tabs, "TABTITLE4", "Tree");
    IupSetAttribute(tabs, "TABTITLE5", "Plot");
    IupSetCallback(tabs, "TABCHANGE_CB", (Icallback)tabs_change);
    IupSetAttribute(tabs, "EXPAND", "YES");

    /* ===== Status Bar ===== */
    Ihandle *status = IupLabel("Ready");
    IupSetAttribute(status, "EXPAND", "HORIZONTAL");
    IupSetAttribute(status, "FGCOLOR", "255 255 255");
    IupSetAttribute(status, "BGCOLOR", "50 50 60");

    /* ===== Main Dialog ===== */
    Ihandle *dlg = IupDialog(
        IupVbox(
            IupScrollBox(tabs),
            IupSetAttributes(IupLabel(""), "SEPARATOR=HORIZONTAL"),
            status,
            NULL));
    IupSetAttribute(dlg, "TITLE", "IUP GUI Demo v3.32");
    IupSetAttribute(dlg, "SIZE", "900x600");
    IupSetAttribute(dlg, "MENU", "MENU");

    /* ===== Menu ===== */
    Ihandle *menu = IupMenu(
        IupSubmenu("&File",
            IupMenu(
                IupItem("&New\tCtrl+N", NULL),
                IupItem("&Open...\tCtrl+O", NULL),
                IupSeparator(),
                IupItem("E&xit", "exit_cb"),
                NULL)),
        IupSubmenu("&Help",
            IupMenu(
                IupItem("&About...", NULL),
                NULL)),
        NULL);
    IupSetHandle("MENU", menu);
    IupSetFunction("exit_cb", (Icallback)exit_cb);

    /* ===== Show ===== */
    IupShowXY(dlg, IUP_CENTER, IUP_CENTER);
    IupMainLoop();
    IupClose();

    printf("Demo exited cleanly.\n");
    return 0;
}
