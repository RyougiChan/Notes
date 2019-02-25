import React from 'react';
import {render} from 'react-dom';
import Greeter from './Greeter';

import './main.css';//使用require导入css文件

render(<Greeter />, document.getElementById('root'));

if(module.hot)
{
    module.hot.accept('./Greeter.js', () => {
        console.log('Accepting the updated Greeter');
        window.location.reload();
    });
}