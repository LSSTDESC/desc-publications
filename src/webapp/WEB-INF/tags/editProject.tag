<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%@attribute name="projid" required="true"%>
<%@attribute name="swgid" required="true"%>  
<%@attribute name="returnURL" required="true" %>

<script src="../js/jquery-1.11.1.min.js"></script>
<script src="../js/jquery.validate.min.js"></script>
<link rel="stylesheet" href="css/pubstyles.css">

 
    <c:if test="${!(gm:isUserInGroup(pageContext,'lsst-desc-members'))}">
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>  
        
    <c:set var="wglist" value=""/>
    <%-- 'state' becomes the value for 'projectstatus' in the descpub_project table --%>
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
        select p.id, p.title, p.summary, p.projectstatus, p.confluenceurl, p.gitspaceurl, s.swg_id, p.taskforce, to_char(p.created,'YYYY-Mon-DD HH:MI:SS') crdate, 
        to_char(p.lastmodified,'YYYY-Mon-DD HH:MI:SS') moddate from descpub_project p join descpub_project_swgs s on s.project_id = p.id
        where p.id=?
        <sql:param value="${projid}"/>
    </sql:query>
        
    <sql:query var="activities"> <%-- make a list of the activities and deliverables --%>
        select trim(activity_id) as activity_id, title from descpub_srm_activities order by activity_id
    </sql:query>

    <sql:query var="deliverables">
        select trim(deliverable_id) as deliverable_id, title from descpub_srm_deliverables order by deliverable_id
    </sql:query>     
        
     <%-- see if the project has any srms attached to it. id should be unique so just check for srm_id in both activity and deliverable --%>
    <sql:query var="projsrm">
       select srm_id from descpub_project_srm_info where project_id = ?
       <sql:param value="${projid}"/>
    </sql:query>
       
    <sql:query var="tforce">
        select tfname from descpub_taskforce order by lower(tfname)
    </sql:query>
       
    <c:set var="title" value="${projects.rows[0].title}"/>
    <c:set var="projstate" value="${projects.rows[0].projectstatus}"/>
    <c:set var="summary" value="${projects.rows[0].summary}"/>
    <%-- <c:set var="comm" value="${projects.rows[0].comm}"/> not used --%>
    <c:set var="confluenceurl" value="${projects.rows[0].confluenceurl}"/>
    <c:set var="gitspace" value="${projects.rows[0].gitspaceurl}"/>
    <c:set var="projectGrpName" value="project_${projid}"/>
    <c:set var="projectleadsGrpName" value="project_leads_${projid}"/>
    <c:set var="taskforce" value="${projects.rows[0].taskforce}"/>
    
    <%--
    <sql:query var="isLead">
        select count(*) tot from profile_ug where group_id = ? and user_id = ?
        <sql:param value="${projectleadsGrpName}"/>
        <sql:param value="${userName}"/>
    </sql:query>
    <c:set var="canEdit" value="${isLead.rows[0].tot > 0 ? 'true' : 'false'}"/> --%>
    
    <p id="pagelabel">Project Details [Working Group(s): ${wglist}]</p>
    <div id="formRequest">
    <fieldset class="fieldset-auto-width">
    <legend>Edit project details</legend>
    <form action="modifySWGprojects.jsp" method="post">  
      <input type="hidden" name="swgid" id="swgid" value="${swgcurr.rows[0].id}" />
      <input type="hidden" name="projid" id="projid" value="${projid}" /> 
      <input type="hidden" name="redirectURL" id="redirectURL" value="projectView.jsp?projid=${projid}&swgid=${projects.rows[0].swg_id} />  
    
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
    
    Status:<br/>  
    <select name="projectstatus" id="projectstatus" size="${validStates.rowCount}" required>
        <c:forEach var="sta" items="${validStates.rows}" >
           <option value="${sta.state}" <c:if test="${fn:startsWith(sta.state,projstate)}">selected</c:if> >${sta.state}</option>
        </c:forEach>
    </select> 
    <p/>
    Primary Confluence URL:<br/>
    <input type="text" name="confluenceurl" id="confluenceurl" value="${confluenceurl}" size="55" required/>
    <p/>
    <p/>
    Primary Github URL:<br/>
    <input type="text" name="gitspaceurl" id="gitspaceurl" value="${gitspace}" size="55" required/>
    <p/>
    
    Taskforce: <br/>
    <select name="selectedtf">
        <option value="none"></option>
         <c:forEach var="t" items="${tforce.rows}">
            <c:set var="selected" value=""/>
            <c:if test="${t.tfname == taskforce}">
               <c:set var="selected" value="selected"/>
            </c:if>
           <option value="${t.tfname}" ${selected}>${t.tfname} </option>
        </c:forEach>
     </select>
   
    <p/>
    
    </p>
    SRM Activities (optional)<br/>
     <select name="srmactivity_id" size="20" multiple>
         <option value="none"></option>
         <c:forEach var="s" items="${activities.rows}">
            <c:set var="selected" value=""/>
            <c:forEach var="p" items="${projsrm.rows}">
                <c:if test="${p.srm_id == s.activity_id}">
                   <c:set var="selected" value="selected"/>
                </c:if>
           </c:forEach>
           <option value="${s.activity_id}" ${selected}>${s.activity_id} &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ${s.title}</option>
        </c:forEach>
     </select>
    <p/>
   
    <p>
    SRM Deliverables (optional)<br/>
     <select name="srmdeliverable_id" size="20" multiple>
        <option value="none"></option>
        <c:forEach var="d" items="${deliverables.rows}">
            <c:set var="selected" value=""/>
            <c:forEach var="px" items="${projsrm.rows}">
                <c:if test="${px.srm_id == d.deliverable_id}">
                    <c:set var="selected" value="selected"/>
                </c:if>
            </c:forEach>
            <option value="${d.deliverable_id}" ${selected}>${d.deliverable_id} &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ${d.title}</option>    
        </c:forEach>
     </select>
    
    <p/>
 
    <p> 
    Brief Summary:<br/> <textarea id="summary" rows="8" cols="50" name="summary" required >${summary}</textarea>
    <p/>
    <%--
    <c:if test="${canEdit || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,'GroupManagerAdmin')}">
      <input type="submit" value="Update_Project_Details" id="action" name="action" />
    </c:if>  --%>
      
    <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,projectleadsGrpName) || gm:isUserInGroup(pageContext,projectGrpName)}">
      <input type="submit" value="Update_Project_Details" id="action" name="action" />
      <input type="reset" value="Reset" id="reset" name="reset" />
    </c:if>  
      
  </form>
    </fieldset>
</div>
<p/>