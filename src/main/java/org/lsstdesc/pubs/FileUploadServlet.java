package org.lsstdesc.pubs;

import java.io.File;
import java.io.IOException;
import java.util.List;
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
        response.setContentType("text/html;charset=UTF-8");
        boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        if (isMultipart) {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletContext servletContext = this.getServletConfig().getServletContext();
            File repository = (File) servletContext.getAttribute("javax.servlet.context.tempdir");
            factory.setRepository(repository);
            ServletFileUpload upload = new ServletFileUpload(factory);
            String forwardTo = null;
            try {
                List<FileItem> items = upload.parseRequest(request);

                for (FileItem item : items) {
                    if (!item.isFormField()) {
                        File file = new File(baseDir, item.getName());
                        try {
                            item.write(file);
                            request.setAttribute("msg", "File save as " + file);
                        } catch (Exception ex) {
                            request.setAttribute("msg", "Error saving file " + ex);
                        }
                    } else if ("forwardTo".equals(item.getFieldName())) {
                        forwardTo = item.getString();
                    }
                }
                if (forwardTo == null) throw new ServletException("Missing forwardTo parameter");
                getServletContext().getRequestDispatcher(forwardTo).forward(request, response);

            } catch (FileUploadException ex) {
                throw new ServletException("Error uploading file", ex);
            }

        } else {
            throw new ServletException("No file to upload");
        }

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
