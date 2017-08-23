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
    <srs_utils:conditonalLink name="Working Groups" url="${pageContext.request.contextPath}/index.jsp" /> |
    <srs_utils:conditonalLink name="Projects" url="${pageContext.request.contextPath}/projects.jsp" /> |
    <srs_utils:conditonalLink name="Publications" url="${pageContext.request.contextPath}/all_publications.jsp" /> |
    <srs_utils:conditonalLink name="Members" url="${pageContext.request.contextPath}/members.jsp" /> |
    <srs_utils:conditonalLink name="Publication Board" url="https://confluence.slac.stanford.edu/display/LSSTDESC/Publications+Board"/> |
    <srs_utils:conditonalLink name="Publication Policy" url="https://confluence.slac.stanford.edu/download/attachments/213901083/LSST_DESC_Publication_Policy_v6_15aug2016.pdf?version=1&modificationDate=1471454511000&api=v2"/> 
</div>