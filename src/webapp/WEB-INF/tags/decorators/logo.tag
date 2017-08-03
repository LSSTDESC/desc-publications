<%@tag description="Tag to import the menu bar" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@attribute name="url" required="false"%>
<%@attribute name="title" required="false"%>



<c:if test="${ empty url }">
    <c:set var="url" value="https://srs.slac.stanford.edu/ImageHandler/imageServlet.jsp?experimentName=LSST-DESC&name=logo&skipExperimentFilter=true"/>
</c:if>

<p/>
<table>
    <tr>
        <td align="middle">
            <img  height="90" width="246" src="${url}"/>
        </td>
        <td align="middle">
            <h1>${experiment} ${title}</h1>
        </td>
    </tr>
</table>
