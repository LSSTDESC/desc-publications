<%-- 
    Document   : toplinks
    Created on : Aug 30, 2017, 1:24:53 PM
    Author     : chee
--%>
<%@tag description="header decorator" pageEncoding="UTF-8"%>
<%@taglib prefix="login" uri="http://srs.slac.stanford.edu/login" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<table>
    <tr>
        <td align="right">
            <c:set var="useDelim" value="false"/>
    <c:if test="${! empty initParam.version}">
        Version:&nbsp;${initParam.version}&nbsp;
            <c:set var="useDelim" value="true"/>
    </c:if>
    <c:if test="${! empty initParam.buildTime}">
        <c:if test="${useDelim}">
        |
        </c:if>
        Built:&nbsp;${initParam.buildTime}&nbsp;
    </c:if>
</td>
</tr>
<tr>
        <td align="right">
<login:login url="${currentPage}" useQueryString="true"/>
<c:if test="${! empty initParam.helpDocumentationUrl}">
    |
    <a href="${initParam.helpDocumentationUrl}">Help</a>
</c:if>
<c:if test="${!empty initParam.jiraUrl}" >
    |
    <a href="${initParam.jiraUrl}">Jira</a>
</c:if>
</td>
</tr>
</table>