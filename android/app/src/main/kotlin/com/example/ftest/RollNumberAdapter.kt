package com.example.ftest

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class RollNumberAdapter(
    private val rollNumbers: List<String>,
    private val rollNumberStatusMap: Map<String, Map<String, Any>>
) : RecyclerView.Adapter<RollNumberAdapter.RollNumberViewHolder>() {

    inner class RollNumberViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val rollNumberTextView: TextView = itemView.findViewById(R.id.rollNumberTextView)
        private val crossIcon: ImageView = itemView.findViewById(R.id.crossIcon)
        private val tickIcon: ImageView = itemView.findViewById(R.id.tickIcon)

        fun bind(rollNumber: String) {
            rollNumberTextView.text = rollNumber
            val rollNumberData = rollNumberStatusMap[rollNumber]
            if (rollNumberData != null && rollNumberData["isPresent"] == true) {
                // Roll number is present, show the tick icon
                crossIcon.visibility = View.GONE
                tickIcon.visibility = View.VISIBLE
            } else {
                // Roll number is not present or isPresent is false, show the cross icon
                crossIcon.visibility = View.VISIBLE
                tickIcon.visibility = View.GONE
            }
        }

    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RollNumberViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.list_item_layout, parent, false)
        return RollNumberViewHolder(view)
    }

    override fun onBindViewHolder(holder: RollNumberViewHolder, position: Int) {
        val rollNumber = rollNumbers[position]
        holder.bind(rollNumber)
    }

    override fun getItemCount(): Int {
        return rollNumbers.size
    }
}

