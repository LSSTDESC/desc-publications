package org.lsstdesc.pubs;

import java.io.File;
import java.io.IOException;
import java.util.List;

import java.sql.Connection;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 * A servlet for uploading documents using apache file upload
 *
 * @author tonyj
 */
public class FileUploadServlet extends HttpServlet {
    
    private File baseDir;

    @Override
    public void init() throws ServletException {
        super.init();
        baseDir = new File(getInitParameter("baseDir"));
    }

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        if (isMultipart) {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletContext servletContext = this.getServletConfig().getServletContext();
            File repository = (File) servletContext.getAttribute("javax.servlet.context.tempdir");
            factory.setRepository(repository);
            ServletFileUpload uploadPub = new ServletFileUpload(factory);

            String forwardTo = null;
            int paperid = 0;
            String remarks = null;
            FileItem file = null;

            try {
                List<FileItem> items = uploadPub.parseRequest(request);

                for (FileItem item : items) {

                    if (!item.isFormField()) {
                        file = item;
                    } else if ("forwardTo".equals(item.getFieldName())) {
                        forwardTo = item.getString();
                    } else if ("paperid".equals(item.getFieldName())) {
                        paperid = Integer.parseInt(item.getString());
                    } else if ("remarks".equals(item.getFieldName())) {
                        remarks = item.getString();
                    }
                }

                if (paperid == 0) {
                    throw new ServletException("Missing paper id");
                }
                if (file == null) {
                    throw new ServletException("Missing file");
                }
                if (forwardTo == null) {
                    throw new ServletException("Missing forwardTo parameter");
                }

                try (Connection conn = ConnectionManager.getConnection(request)) {
                    DBUtilities dbUtil = new DBUtilities(conn);
                    int nextVersion = dbUtil.getMaxExistingVersion(paperid) + 1;
                    int projId = dbUtil.getProjectForPaper(paperid);
                    checkIfPDF(file);
                    File saveFile = getPathForFile(paperid, projId, nextVersion);
                    file.write(saveFile);
                    dbUtil.insertPaperVersion(paperid, nextVersion, remarks, file.getName(), saveFile.getPath());
                    dbUtil.commit();
                    request.setAttribute("msg", "File saved as " + saveFile.getName());
                } catch (Exception ex) {
                    request.setAttribute("msg", "Error saving file: " + ex.getMessage());
                }
                getServletContext().getRequestDispatcher(forwardTo).forward(request, response);

            } catch (FileUploadException ex) {
                throw new ServletException("Error uploading file", ex);
            } 
        } else {
            throw new ServletException("No file to upload");
        }
    }

    private void checkIfPDF(FileItem item) throws IOException, ServletException {
        byte[] b = new byte[4];
        item.getInputStream().read(b);
        if (b[0] != '%' || b[1] != 'P' || b[2] != 'D' || b[3] != 'F') {
            throw new ServletException("Uploaded file is not in PDF format");
        }
    }

    private File getPathForFile(int paperid, int projId, int version) {
        File result = new File(baseDir, String.format("Project-%d/Paper-%d/DESC-%d_v%d.pdf", projId, paperid, paperid, version));
        result.getParentFile().mkdirs();
        return result;
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
        protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
        public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
