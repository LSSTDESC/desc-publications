<%@tag description="header decorator" pageEncoding="UTF-8"%>
<%@taglib prefix="dec" tagdir="/WEB-INF/tags/decorators" %>

<table>
    <tr align="right" valign="bottom">
        <td align="right" valign="bottom">
            <dec:toplinks/>
        </td>
    </tr>
    <tr align="right" valign="bottom">
        <td align="right" valign="bottom">
            <dec:experimentLink/>
        </td>
    </tr>
    <tr align="right" valign="bottom">
        <td align="right" valign="bottom">
            <dec:middlelinks/>
        </td>
    </tr>
    <tr align="right" valign="bottom">
        <td align="right" valign="bottom">
            <dec:bottomlinks/>
        </td>
    </tr>
</table>
