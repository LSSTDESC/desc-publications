<%@tag description="Tag to import the menu bar" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@attribute name="url" required="false"%>
<%@attribute name="title" required="false"%>



<c:if test="${ empty url }">
    <c:set var="url" value="https://srs.slac.stanford.edu/ImageHandler/imageServlet.jsp?experimentName=LSST-DESC&name=logo"/>
</c:if>

<c:url var="logoUrl" value="${url}">
    <c:param name="experiment" value="${appVariables.experiment}"/>
    <c:param name="name" value="logo"/>
    <c:param name="skipExperimentFilter" value="true"/>
</c:url>


<table>
    <tr>
        <td align="middle">
            <img  height="140" width="230" src="${logoUrl}"/>
        </td>
        <td align="middle">
            <h1>${experiment} ${title}</h1>
        </td>
    </tr>
</table>
