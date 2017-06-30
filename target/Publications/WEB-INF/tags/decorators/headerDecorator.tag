<%@tag description="header decorator" pageEncoding="UTF-8"%>
<%@taglib prefix="dec" tagdir="/WEB-INF/tags/decorators" %>

<table width="100%" >
    <tr>
        <td>
            <dec:menuBar/>
        </td>
    </tr>
    <tr>
        <td>
            <table width="100%">
                <tr>
                    <td>
                        <dec:logo />
                    </td>
                    <td>
                        <dec:middleHeader/>
                    </td>
                    <td align="right" valign="bottom">
                        <dec:rightHeader/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
