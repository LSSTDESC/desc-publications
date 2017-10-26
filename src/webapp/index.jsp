<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm"%>
<%@taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils"%>
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
    
    <tg:underConstruction/>

    <p/>
     <c:set var="convenLink" value="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/group.jsp?name="/>
        
        <c:set var="memberPool" value="lsst-desc-full-members"/>

        <sql:query var="swgs">
            select id, name, profile_group_name as pgn, convener_group_name as cgn from descpub_swg 
            order by id
        </sql:query>

        <c:if test="${swgs.rowCount > 0}">
            <display:table class="datatable"  id="Row" name="${swgs.rows}">
                <display:column title="Working Groups" sortable="true" headerClass="sortable">
                    <a href="show_swg.jsp?swgid=${Row.id}&swgname=${Row.name}">${Row.name}</a>
                </display:column>
                <display:column title="Working Group Conveners" sortable="true" headerClass="sortable">
                    <sql:query var="conveners">
                        select me.firstname, me.lastname, me.memidnum from um_member me join profile_ug ug on me.memidnum=ug.memidnum and ug.group_id=?
                        <sql:param value="${Row.cgn}"/>
                    </sql:query>
                    <c:if test="${conveners.rowCount>0}">
                        <c:forEach var="c" items="${conveners.rows}">
                            <a href="http://srs.slac.stanford.edu/GroupManager/exp/${appVariables.experiment}/protected/user.jsp?memidnum=${c.memidnum}&recType=INDB&verification=">${c.firstname} ${c.lastname}</a><br/>
                        </c:forEach>
                    </c:if>
                </display:column>
                <display:column title="Update Working Group Members (Admins Only)">
                    <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/group.jsp?name=${Row.cgn}">${Row.cgn}</a>
                </display:column>
            </display:table>
        </c:if>     

    </body>

</html>
