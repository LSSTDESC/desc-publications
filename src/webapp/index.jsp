<%-- 
    Document   : publications
    Created on : Jun 30, 2017, 10:30:01 AM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>

<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="js/jquery-1.11.1.min.js"></script>
        <script src="js/jquery.validate.min.js"></script>
        <link rel="stylesheet" href="css/site-demos.css">
        <title>LSST DESC Publications Board</title>
    </head>


<body>
     
    <h1> <img name="construction" src="Images/construction.gif" border=0>   
        THE DESC PUBLICATION SYSTEM IS A WORK IN PROGRESS.  
    </h1>
    <p/>
     <c:set var="convenLink" value="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/group.jsp?name="/>
        
     <h2><a href="https://confluence.slac.stanford.edu/display/LSSTDESC/Publications+Board">LSST-DESC Publications Board</a></h2>
     
        <c:set var="memberPool" value="lsst-desc-full-members"/>

        <sql:query var="swgs" dataSource="jdbc/config-dev">
            select id, name, email, profile_group_name as pgn, convener_group_name as cgn from descpub_swg 
            order by id
        </sql:query>


        <c:if test="${swgs.rowCount > 0}">
            <display:table class="datatable"  id="Row" name="${swgs.rows}">
                <display:column title="Science Working Group" sortable="true" headerClass="sortable">
                    <a href="show_swg.jsp?swgid=${Row.id}&swgname=${Row.name}">${Row.name}</a>
                </display:column>
                <display:column title="Mail List" sortable="true" headerClass="sortable">
                    <a href="mailto:${Row.email}">${Row.email}</a>
                </display:column>
                <display:column title="Working Group Members" sortable="true" headerClass="sortable">
                    <sql:query var="conveners" dataSource="jdbc/config-dev">
                        select me.firstname, me.lastname from um_member me join profile_ug ug on me.memidnum=ug.memidnum and ug.group_id=?
                        <sql:param value="${Row.cgn}"/>
                    </sql:query>
                    <c:if test="${conveners.rowCount>0}">
                        <display:table class="datatable" id="cRow" name="${conveners.rows}"/>
                    </c:if>
                </display:column>
            </display:table>
        </c:if>     

    </body>

</html>
