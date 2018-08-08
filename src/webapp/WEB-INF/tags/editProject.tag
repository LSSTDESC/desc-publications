<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%@attribute name="projid" required="true"%>
<%@attribute name="swgid" required="true"%>  
<%@attribute name="returnURL" required="true" %>
<link rel="stylesheet" href="css/pubstyles.css">

 
    <c:if test="${!(gm:isUserInGroup(pageContext,'lsst-desc-members'))}">
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>  
   
    <c:set var="wglist" value=""/>
    <sql:query var="validStates">
        select state from descpub_project_states order by state
    </sql:query>
    
    <%-- project can have multiple working groups assigned so execute separate query and make a list of relevant working groups --%> 
    <sql:query var="swgcurr">
         select wg.name, wg.id from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ? order by wg.name
        <sql:param value="${projid}"/>
    </sql:query>  
    
    <c:forEach var="wg" items="${swgcurr.rows}">
       <c:choose>
           <c:when test="${empty wglist}">
               <c:set var="wglist" value="${wg.name}"/>
           </c:when>
           <c:when test="${!empty wglist}">
               <c:set var="wglist" value="${wglist},${wg.name}"/>
           </c:when>
       </c:choose>
     </c:forEach>

         
    <sql:query var="swgcandidates">
        select name, id from descpub_swg where name not in 
        (select wg.name from descpub_swg wg join descpub_project_swgs ps on wg.id = ps.swg_id where ps.project_id = ?) 
        order by name
        <sql:param value="${projid}"/>
    </sql:query>
   
    <sql:query var="projects">
        select id, title, summary, state, wkspaceurl, gitspaceurl, srmact, to_char(created,'YYYY-Mon-DD HH:MI:SS') crdate, to_char(lastmodified,'YYYY-Mon-DD HH:MI:SS') moddate from descpub_project where id = ?  
        <sql:param value="${projid}"/>
    </sql:query>
    
    <c:set var="project_grp" value="project_${projid}"/>
    <c:set var="title" value="${projects.rows[0].title}"/>
    <c:set var="projstate" value="${projects.rows[0].state}"/>
    <c:set var="summary" value="${projects.rows[0].summary}"/>
    <c:set var="comm" value="${projects.rows[0].comm}"/>
    <c:set var="wkspace" value="${projects.rows[0].wkspaceurl}"/>
    <c:set var="gitspace" value="${projects.rows[0].gitspaceurl}"/>
    <c:set var="srmspace" value="${projects.rows[0].srmact}"/>
    <c:set var="projectleads" value="project_leads_${projid}"/>
    
    <sql:query var="isLead">
        select count(*) tot from profile_ug where group_id = ? and user_id = ?
        <sql:param value="${projectleads}"/>
        <sql:param value="${userName}"/>
    </sql:query>
    <c:set var="canEdit" value="${isLead.rows[0].tot > 0 ? 'true' : 'false'}"/>
    
<p id="pagelabel">Project Details [Working Group(s): ${wglist}]</p>
<div id="formRequest">
    <fieldset class="fieldset-auto-width">
        <legend>Edit project details</legend>
<form action="modifySWGprojects.jsp" method="post">  
    <input type="hidden" name="swgid" id="swgid" value="${swgcurr.rows[0].id}" />
    <input type="hidden" name="projid" id="projid" value="${projid}" /> 
    <input type="hidden" name="redirectURL" id="redirectURL" value="show_project.jsp?projid=${projid}" />  
    
    Project ID: ${projid} &nbsp;&nbsp;&nbsp;
    Created: ${projects.rows[0].crdate}&nbsp;&nbsp;&nbsp;
    <c:if test="${!empty projects.rows[0].moddate}">
        Last changed: ${projects.rows[0].moddate}<p/>
        <c:if test="${!empty projects.rows[0].lastmodby}">
          Last changed by: ${projects.rows[0].lastmodby}<br/>
        </c:if>
    </c:if>
    <p/>
    Title: <br/><input type="text" name="title" id="title" value="${title}" size="55" required/><p/>
    <table border="0">
        <tr><td>Add working group</td><td>Remove working group</td></tr>
        <tr>
            <td><select name="addprojswg" id="addprojswg" size="8" multiple>
            <c:forEach var="addrow" items="${swgcandidates.rows}">
              <option value="${addrow.id}">${addrow.name}</option>
            </c:forEach>
            </select></td>
            <td> 
            <select name="removeprojswg" id="removeprojswg" size="8" multiple>
            <c:forEach var="remrow" items="${swgcurr.rows}">
              <option value="${remrow.id}">${remrow.name}</option>
            </c:forEach>
            </select> 
            </td>
        </tr>
    </table>
    <p/>
    
    State:<br/>  
    <select name="state" id="state" size="6" required>
        <c:forEach var="sta" items="${validStates.rows}" >
           <option value="${sta.state}" <c:if test="${fn:startsWith(sta.state,projstate)}">selected</c:if> >${sta.state}</option>
        </c:forEach>
    </select> 
    <p/>
    Confluence URL:<br/>
    <input type="text" name="wkspaceurl" id="wkspaceurl" value="${wkspace}" size="55" required/>
    <p/>
    <p/>
    Github URL:<br/>
    <input type="text" name="gitspaceurl" id="gitspaceurl" value="${gitspace}" size="55" required/>
    <p/>
    SRM activity:<br/>
    <input type="text" name="srmact" id="srmact" value="${srmspace}" size="55" required/>
    <p/>
    Brief Summary:<br/> <textarea id="summary" rows="8" cols="50" name="summary">${summary}</textarea>
    <p/>
    
    <c:if test="${canEdit || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,'GroupManagerAdmin')}">
      <input type="submit" value="Update_Project_Details" id="action" name="action" />    
    </c:if>  
  </form>
    </fieldset>
</div>
<p/>