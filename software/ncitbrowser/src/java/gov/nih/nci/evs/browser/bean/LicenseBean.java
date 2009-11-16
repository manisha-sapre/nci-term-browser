package gov.nih.nci.evs.browser.bean;

import java.io.*;
import java.util.HashSet;
import java.util.Vector;

import org.LexGrid.LexBIG.DataModel.Core.CodingSchemeVersionOrTag;
import org.LexGrid.LexBIG.LexBIGService.LexBIGService;
import org.LexGrid.codingSchemes.CodingScheme;
import org.LexGrid.LexBIG.Exceptions.LBException;

//import gov.nih.nci.evs.browser.utils.RemoteServerUtil;
import gov.nih.nci.evs.browser.utils.*;
import gov.nih.nci.evs.browser.properties.NCItBrowserProperties;
import gov.nih.nci.evs.browser.common.Constants;


/**
 * <!-- LICENSE_TEXT_START -->
 * Copyright 2008,2009 NGIT. This software was developed in conjunction with the National Cancer Institute,
 * and so to the extent government employees are co-authors, any rights in such works shall be subject to Title 17 of the United States Code, section 105.
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the disclaimer of Article 3, below. Redistributions
 * in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other
 * materials provided with the distribution.
 * 2. The end-user documentation included with the redistribution, if any, must include the following acknowledgment:
 * "This product includes software developed by NGIT and the National Cancer Institute."
 * If no such end-user documentation is to be included, this acknowledgment shall appear in the software itself,
 * wherever such third-party acknowledgments normally appear.
 * 3. The names "The National Cancer Institute", "NCI" and "NGIT" must not be used to endorse or promote products derived from this software.
 * 4. This license does not authorize the incorporation of this software into any third party proprietary programs. This license does not authorize
 * the recipient to use any trademarks owned by either NCI or NGIT
 * 5. THIS SOFTWARE IS PROVIDED "AS IS," AND ANY EXPRESSED OR IMPLIED WARRANTIES, (INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE) ARE DISCLAIMED. IN NO EVENT SHALL THE NATIONAL CANCER INSTITUTE,
 * NGIT, OR THEIR AFFILIATES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <!-- LICENSE_TEXT_END -->
 */

/**
 * @author EVS Team
 * @version 1.0
 *
 * Modification history
 *     Initial implementation kim.ong@ngc.com
 *
 */

public class LicenseBean extends Object {

    HashSet licenseAgreementHashSet = null;

    public LicenseBean() {
        licenseAgreementHashSet = new HashSet();
    }

    public void addLicenseAgreement(String scheme) {
		System.out.println("LicenseBean addLicenseAgreement " +  scheme);
		licenseAgreementHashSet.add(scheme);
	}

    public boolean licenseAgreementAccepted(String scheme) {
        // option to not pop-up the license agreement page:
		String license_page_option = NCItBrowserProperties.getLicensePageOption();
		if (license_page_option.compareToIgnoreCase("true") != 0) return true;

		boolean retval = licenseAgreementHashSet.contains(scheme);
		return (retval);
	}

    public static boolean isLicensed(String codingSchemeName, String version) {
		//MedDRA, SNOMED CT, and UMLS Semantic Network.
/*
	    String s = resolveCodingSchemeCopyright(codingSchemeName, version);
	    if (s == null || s.compareTo("") == 0 || (s.indexOf("Copyright information unavailable") != -1)) return false;
	    return true;
*/
/*
        if (codingSchemeName.indexOf("MedDRA") != -1 || codingSchemeName.indexOf("SNOMED") != -1 || codingSchemeName.indexOf("Semantic Net") != -1) return true;
        return false;
*/


        String download_license = null;
        download_license = DataUtils.getMetadataValue(codingSchemeName, download_license);
        if (download_licensecompareTo("accept") == 0) return true;

        // to be removed:
        else if (download_license == null && resolveCodingSchemeCopyright(codingSchemeName, version) != null) return true;

        return false;
    }


	public static String resolveCodingSchemeCopyright(String codingSchemeName, String version) {
		LexBIGService lbs = RemoteServerUtil.createLexBIGService();
		CodingSchemeVersionOrTag versionOrTag = new CodingSchemeVersionOrTag();
		if (version != null) versionOrTag.setVersion(version);
		String copyRightStmt = null;
		try {
			/*
			String urn = null;
			if (version == null) {
				version = DataUtils.getVocabularyVersionByTag(codingSchemeName, "PRODUCTION");
				if (version == null) version = DataUtils.getVocabularyVersionByTag(codingSchemeName, null);
			}
			Vector v = MetadataUtils.getMetadataValues(codingSchemeName, version, urn, Constants.LICENSE_STATEMENT);
			if (v != null && v.size() > 0) return (String) v.elementAt(0);

			//copyRightStmt = lbs.resolveCodingSchemeCopyright(codingSchemeName, versionOrTag);
			*/
			copyRightStmt = DataUtils.getMetadataValue(codingSchemeName, Constants.LICENSE_STATEMENT);
		} catch (Exception ex) {
		}
		return copyRightStmt;
	}

}