package com.example.maps

import android.content.Context
import androidx.appcompat.app.AlertDialog


/**
 * @author: Shashi
 * @date : 30-11-2021
 * @description : Utils
 **/
/**
 * Shows alert dialog
 */
fun Context.showAlertDialog(
    title: String? = null,
    message: String,
    posBtnText:String? = null,
    negBtnText:String? = null,
    showNegBtn:Boolean = true,
    callback: () -> Unit
) {
    AlertDialog.Builder(this).also {
        it.setTitle(title ?: "Alert")
        it.setMessage(message)
        it.setPositiveButton(posBtnText?:"Yes") { _, _ ->
            callback()
        }
        if (showNegBtn) {
            it.setNegativeButton(negBtnText?:"No") { dialog, _ ->
                dialog.dismiss()
            }
        }
    }.create().show()
}