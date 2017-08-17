<%-- 
    Document   : editPublication
    Created on : Aug 8, 2017, 12:30:24 PM
    Author     : chee
--%>
<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="time" uri="http://srs.slac.stanford.edu/time" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<script src="js/jquery-1.11.1.min.js"></script>
<script src="js/jquery.validate.min.js"></script>

<%@attribute name="pubid" required="true"%>
<%@attribute name="projid" required="true"%>
<%@attribute name="swgid" required="true"%>

 <sql:query var="pubtypes" dataSource="jdbc/config-dev">
     select pubtype from descpub_pubtypes order by pubtype
 </sql:query>

 <sql:query var="pubs" dataSource="jdbc/config-dev">
    select dp.ID pubid,pj.id projid,dp.STATE,dp.TITLE pubtitle,dp.JOURNAL,dp.PUBTYPE,dp.ABSTRACT,to_char(dp.ADDED,'YYYY-MON-DD') ADDED,dp.BUILDER_ELIGIBLE,dp.COMMENTS,dp.KEYPUB,dp.CWR_END_DATE,
    dp.ASSIGNED_PB_READER,dp.CWR_COMMENTS,dp.ARXIV,dp.TELECON,dp.JOURNAL_REVIEW,dp.PUBLISHED_REFERENCE,dp.PROJECT_ID,pj.TITLE 
    FROM descpub_publication dp join descpub_project pj on pj.id = dp.project_id where pj.id = ? and dp.id = ?
   <sql:param value="${projid}"/>
   <sql:param value="${pubid}"/>
  </sql:query>  
    
<sql:query var="pubtypes" dataSource="jdbc/config-dev">
    select pubtype from descpub_pubtypes order by pubtype
</sql:query>
    
<sql:query var="states" dataSource="jdbc/config-dev">
    select state from descpub_publication_states order by state
</sql:query>
 
<sql:query var="projinfo" dataSource="jdbc/config-dev">
    select title from descpub_project where id = ?
   <sql:param value="${projid}"/>
</sql:query>
<sql:query var="wgs" dataSource="jdbc/config-dev">
    select wg.name, wg.id, wg.convener_group_name, wg.profile_group_name from descpub_project_swgs jo join descpub_swg wg on jo.swg_id = wg.id
    where jo.project_id = ?
    <sql:param value="${projid}"/>
</sql:query>
    
<h3>Publication: [${param.pubid}] ${pubs.rows[0].title} </h3>
    Added: ${pubs.rows[0].added}<br/>
    Project: <a href="show_project.jsp?projid=${projid}&swgid=${pubs.rows[0].swgid}&name=${pubs.rows[0].projtitle}">${pubs.rows[0].projtitle}</a><br/>
 
    
<form action="modifyPublication.jsp">  
   <input type="hidden" name="id" value="${pubid}"/> 
   <input type="hidden" name="project_id" value="${projid}"/> 
   <input type="hidden" name="swgid" value="${swgid}"/> 
   Title: <input type="text" value="${pubs.rows[0].pubtitle}" size="35" name="title" required/><br/>
   State: 
   <select name="state" id="pubstate">
       <c:forEach var="sta" items="${states.rows}">
           <c:if test="${fn:startsWith(pubs.rows[0].state,sta.state)}">
               <option value="${sta.state}" selected>${sta.state}</option>
           </c:if>
               <option value="${sta.state}">${sta.state}</option>
       </c:forEach>
   </select>
   <p/>
   
   Journal: <input type="text" value="${pubs.rows[0].JOURNAL}" size="35" name="journal"/><br/>
   Journal_Review: <input type="text" value="${pubs.rows[0].JOURNAL_REVIEW}" size="3" name="journal_review"/><br/>
   Pubtype: <select name="pubtype">
        <c:forEach var="ptype" items="${pubtypes.rows}">
            <option value="${ptype.pubtype}" <c:if test="${pubs.rows[0].pubtype == ptype.pubtype}">selected</c:if>  >${ptype.pubtype}</option>
        </c:forEach>
    </select>
   <br/>
   
   Builder Eligible: <input type="text" value="${pubs.rows[0].BUILDER_ELIGIBLE}" size="3" name="builder_eligible"/><br/>
   Key Publication: <input type="text" value="${pubs.rows[0].KEYPUB}" size="3" name="keypub"/><br/>
   Assigned PB Reader: <input type="text" value="${pubs.rows[0].ASSIGNED_PB_READER}" size="35" name="assigned_pb_reader"/><br/>
   
   Abstract: <br/>
   <textarea name="abstract" rows="10" cols="60" required>${pubs.rows[0].ABSTRACT}</textarea><br/>
   
   Comments: <br/>
   <textarea name="comments" rows="10" cols="60">${pubs.rows[0].COMMENTS}</textarea><br/>
   
   Cwr_Comments: <br/>
   <textarea name="cwr_comments" rows="10" cols="60" >${pubs.rows[0].CWR_COMMENTS}</textarea><br/>
  
   arXiv number: <input type="text" value="${pubs.rows[0].ARXIV}" size="35" name="arxiv"/><br/>
   Telecon: <input type="text" value="${pubs.rows[0].TELECON}" size="35" name="telecon"/><br/>
   Published Reference: <input type="text" value="${pubs.rows[0].PUBLISHED_REFERENCE}" size="35" name="published_reference"/><br/>
   Project Id: ${projid}<br/>
   <p/>
   <input type="submit" value="UpdatePub" name="action" />
</form>  
 
 