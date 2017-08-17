<%-- 
    Document   : bottomlinks
    Created on : Aug 14, 2017, 10:51:05 AM
    Author     : chee
--%>

<%@tag description="header decorator" pageEncoding="UTF-8"%>
<%@taglib prefix="srs_utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm" %>

<div>
    <srs_utils:conditonalLink name="Projects" url="${pageContext.request.contextPath}/projects.jsp" /> |
    <srs_utils:conditonalLink name="Working Groups" url="${pageContext.request.contextPath}/index.jsp" /> |
    <srs_utils:conditonalLink name="Members" url="${pageContext.request.contextPath}/members.jsp" /> 
    
</div>