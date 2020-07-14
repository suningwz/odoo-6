# -*- coding:utf-8 -*-

from odoo import api, fields, models, _
from odoo.tools import DEFAULT_SERVER_DATETIME_FORMAT
from random import randint


class ResUsers(models.Model):
    _inherit = 'res.users'

    def demo_function(self):
        """
        In py3o template, we can use Python expressions
        easy peasy lemon squeezy
        """
        return self.id * 100 / (len(self.child_ids) or 1)

    def prepare_py3o_data(self):
        return {
            'friends': self.env['res.partner'].search([]),
            'today': fields.Datetime.now().strftime(DEFAULT_SERVER_DATETIME_FORMAT)
        }

    @api.multi
    def print_py3o_report_xls(self):
        self.ensure_one()
        report = self.env.ref('report_py3o.res_user_py3o_xls')
        # customized printing file name
        report.write({
            'specific_document_name': 'Whatever #%r' % randint(1, 99)
        })
        return report.report_action(self)

    @api.multi
    def print_py3o_report_pdf(self):
        self.ensure_one()
        report = self.env.ref('report_py3o.res_user_py3o_pdf').report_action(self)
        return report
